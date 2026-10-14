# Studio · Overview (5a). What came in, and what needs the creator today.
class DashboardController < ApplicationController
  before_action :require_user
  before_action :fans_go_home

  RANGES = { "7d" => 7, "30d" => 30, "90d" => 90 }.freeze

  def show
    me = current_user
    approved = me.received_payment_claims.approved

    month = (Time.current.beginning_of_month..)
    last_month = 1.month.ago.beginning_of_month..1.month.ago.end_of_month
    @earned_month = approved.where(reviewed_at: month).sum(:amount_cents)
    earned_last = approved.where(reviewed_at: last_month).sum(:amount_cents)
    @earned_change = earned_last.positive? ? (((@earned_month - earned_last) * 100.0) / earned_last).round : nil

    @collections = me.paid_media_collections.includes(:access_purchases, paid_media_posts: [ :media_attachment, :preview_attachment ])
    @unlocks = AccessPurchase.paid.where(purchasable: @collections).count +
               MediaPurchase.paid.joins(:paid_media_post).where(paid_media_posts: { user_id: me.id }).count

    @close_friends = me.active_close_friends.includes(:subscription_plan).to_a
    @close_friends_monthly = @close_friends.sum { |s| s.subscription_plan.price_cents }

    @list_opens = me.link_lists.sum(:opens_count)
    @list_taps = LinkListItem.joins(:link_list).where(link_lists: { user_id: me.id }).sum(:clicks_count)

    @range = RANGES.key?(params[:range]) ? params[:range] : "30d"
    days = RANGES[@range]
    window = approved.where(reviewed_at: (days - 1).days.ago.beginning_of_day..)
    by_day = window.group("DATE(reviewed_at)").sum(:amount_cents)
    @series = (0...days).map { |i| by_day[(days - 1 - i).days.ago.to_date].to_i }
    @breakdown = {
      "Collections" => window.where(purchasable_type: %w[PaidMediaCollection PaidMediaPost]).sum(:amount_cents),
      "Close Friends" => window.where(purchasable_type: "SubscriptionPlan").sum(:amount_cents),
      "Tips & gifts" => window.where(purchasable_type: "WishlistItem").sum(:amount_cents),
      "Calls & access" => window.where(purchasable_type: %w[MeetSlot ContactReveal]).sum(:amount_cents)
    }

    # Needs you
    @pending = me.received_payment_claims.pending.to_a
    @next_live = me.live_sessions.where(status: %w[scheduled live]).where(scheduled_for: Time.current.beginning_of_day..).order(:scheduled_for).first
    @unread = Conversation.where(creator_id: me.id).sum(:creator_unread_count)
    cf_fans = @close_friends.map(&:subscriber_id)
    @unread_cf = Conversation.where(creator_id: me.id, fan_id: cf_fans).where("creator_unread_count > 0").count
    @next_call = MeetBooking.paid.joins(meet_slot: :meet_offer)
                            .where(meet_offers: { user_id: me.id })
                            .where(meet_slots: { starts_at: Time.current.. })
                            .includes(:attendee, meet_slot: :meet_offer)
                            .order("meet_slots.starts_at").first

    @top_collections = @collections.select(&:published?).sort_by { |c| -c.revenue_cents }.first(4)
  end

  private

  def fans_go_home
    redirect_to(root_path) unless current_user.creator?
  end
end
