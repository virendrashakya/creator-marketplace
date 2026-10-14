# The public storefront at /:handle, and the two fan screens that hang off
# it: joining Close Friends and chipping in to a Spoil Me gift.
#
# Four tabs, in the order a fan should meet them:
#   Posts        free, public posts. No prices anywhere.
#   Collections  only each collection's cover, a lock and a count.
#   Shop         the creator's looks, as affiliate links.
#   Book         calls, lives, paid DMs and private circles.
class ProfilesController < ApplicationController
  TABS = %w[posts collections shop book].freeze
  TAB_ALIASES = {
    "vault" => "collections", "media" => "collections", "unlock" => "collections",
    "recommendations" => "shop", "fits" => "shop", "feed" => "posts",
    "about" => "book", "time" => "book"
  }.freeze

  before_action :load_creator

  def show
    @posts = @user.creator_posts.where(published: true).with_attached_media.order(created_at: :desc)
    @collections = @user.live_collections.includes(paid_media_posts: [ :media_attachment, :preview_attachment ])
    @collections = @collections.reject { |c| c.paid_media_posts.empty? }
    @drops = @user.paid_media_posts.published.standalone.order(created_at: :desc)
    @links = @user.product_links.includes(:link_collection)
    @link_categories = @user.link_collections.select { |c| @links.any? { |l| l.link_collection_id == c.id } }
    @meet_offers = @user.meet_offers.published.includes(meet_slots: :meet_booking).order(:created_at)
    # On now, or still to come. A scheduled live whose time has long passed
    # (never started) is not something to offer a fan.
    @lives = @user.live_sessions.where(unlisted: false)
                  .where("status = ? OR (status = ? AND scheduled_for > ?)", "live", "scheduled", 2.hours.ago)
                  .order(:scheduled_for).limit(3)
    @contact_reveals = @user.contact_reveals.published.order(:price_cents)
    @plan = @user.close_friends_plan
    @wishlist_items = WishlistItem.joins(:wishlist).where(wishlists: { user_id: @user.id, published: true }).where(status: "available")
    @link_lists = @user.link_lists.on_profile.includes(:items).order(updated_at: :desc)

    requested = params[:tab].to_s.downcase
    requested = TAB_ALIASES.fetch(requested, requested)
    @tab = if TABS.include?(requested)
      requested
    elsif @posts.any?
      "posts"
    elsif @collections.any? || @drops.any?
      "collections"
    else
      "posts"
    end

    if @tab == "shop" && params[:cat].present?
      @active_category = @link_categories.find { |c| c.id.to_s == params[:cat].to_s }
      @shown_links = @active_category ? @links.select { |l| l.link_collection_id == @active_category.id } : @links
    else
      @shown_links = @links
    end

    @collection_count = @collections.size + @drops.size
  end

  # 3i. One screen, the plan's perks and its price, then off to pay.
  def close_friends
    @plans = @user.subscription_plans.where(active: true).order(:price_cents)
    return redirect_to(profile_path(@user.handle), alert: "#{@user.first_name} hasn't opened Close Friends yet.") if @plans.empty?

    @plan = @plans.find { |p| p.id.to_s == params[:plan].to_s } || @plans.first
    @member = current_user&.subscribed_to?(@plan)
    @collection_count = @user.live_collections.count
    @next_live = @user.live_sessions.upcoming.where(access: "members").where(scheduled_for: Time.current..).first
    @members = @user.active_close_friends.count
  end

  # 3j. The creator's open gifts, the biggest one first.
  def spoil_me
    @items = WishlistItem.joins(:wishlist).where(wishlists: { user_id: @user.id, published: true })
                         .includes(gift_contributions: :giver).order(:created_at)
    @item = @items.find { |i| i.id.to_s == params[:item].to_s } || @items.find(&:open_for_gifts?) || @items.first
    return redirect_to(profile_path(@user.handle), alert: "#{@user.first_name} has no gifts on their list right now.") unless @item
  end

  private

  def load_creator
    handle = params[:handle].to_s.delete_prefix("@").downcase
    @user = User.find_by!(handle: handle)
    head :not_found if @user.blocks?(current_user)
    @own_page = current_user.present? && current_user == @user
    @following = current_user.present? && !@own_page && current_user.following?(@user)
  end
end
