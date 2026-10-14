# Direct messages. Creators get Studio's three-pane inbox (5g); fans get a
# phone chat (3k). Same threads, same socket, two layouts, chosen by which
# side of the thread you are on.
class ConversationsController < ApplicationController
  before_action :require_user

  FILTERS = %w[all close_friends unread].freeze

  def index
    load_inbox
    # A creator on a wide screen lands in their most recent thread, the way
    # every mail client does; on a phone the list stays the first screen.
    render(current_user.creator? ? "studio" : "index")
  end

  def show
    @conversation = find_participating_conversation
    @other = @conversation.other_party(current_user)
    @messages = @conversation.direct_messages.includes(:sender).chronological.last(200)
    @conversation.mark_read_for!(current_user)
    @creator_side = current_user == @conversation.creator

    if @creator_side
      load_inbox
      @vault = current_user.paid_media_collections.live.order(created_at: :desc).to_a +
               current_user.paid_media_posts.published.standalone.order(created_at: :desc).to_a
      @fan_stats = fan_stats(@other)
      render "studio"
    else
      @creator = @conversation.creator
      @close_friend = current_user.subscribed_to_creator?(@creator)
    end
  end

  # Started from a creator's public page. find_or_create, so pressing
  # "Message" twice lands in the same thread rather than splitting history.
  def create
    handle = params[:handle].to_s.downcase.delete_prefix("@")
    creator = User.find_by!(handle: handle)
    return head :not_found if creator.blocks?(current_user)
    if creator == current_user
      redirect_to conversations_path, alert: "You cannot message yourself." and return
    end

    conversation = Conversation.between(creator: creator, fan: current_user)
    redirect_to conversation_path(conversation)
  end

  private

  def load_inbox
    @filter = params[:filter].presence_in(FILTERS) || "all"
    scope = current_user.conversations.includes(:creator, :fan).recent
    if current_user.creator?
      cf_ids = current_user.active_close_friends.pluck(:subscriber_id)
      @close_friend_ids = cf_ids.to_set
      scope = scope.where(creator_id: current_user.id, fan_id: cf_ids) if @filter == "close_friends"
      scope = scope.where(creator_id: current_user.id).where("creator_unread_count > 0") if @filter == "unread"
    else
      @close_friend_ids = Set.new
    end
    @conversations = scope.limit(100).to_a
    @last_messages = DirectMessage.where(id: DirectMessage.where(conversation_id: @conversations.map(&:id))
                                                          .group(:conversation_id).select("MAX(id)"))
                                  .index_by(&:conversation_id)
  end

  def fan_stats(fan)
    claims = current_user.received_payment_claims.approved.where(claimant: fan)
    sub = fan.creator_subscriptions.joins(:subscription_plan).where(subscription_plans: { user_id: current_user.id })
             .where(status: "active").where("current_period_ends_at > ?", Time.current).order(:created_at).first
    collections = current_user.paid_media_collections.live.to_a
    last_gift = claims.where(purchasable_type: "WishlistItem").order(reviewed_at: :desc).first
    {
      spent: claims.sum(:amount_cents),
      collections: "#{collections.count { |c| c.unlocked_for?(fan) }} of #{collections.size}",
      close_friends: sub ? "since #{sub.created_at.strftime("%b")}" : "No",
      last_gift: last_gift ? "#{last_gift.money_label} · #{wf_short_date(last_gift.reviewed_at)}" : "None"
    }
  end

  def wf_short_date(time) = time&.strftime("%-d %b").to_s

  def find_participating_conversation
    conversation = Conversation.find(params[:id])
    # A thread you are not in is not yours to read. 404 rather than 403: the
    # existence of a thread between two other people is itself private.
    raise ActiveRecord::RecordNotFound unless conversation.participant?(current_user)

    conversation
  end
end
