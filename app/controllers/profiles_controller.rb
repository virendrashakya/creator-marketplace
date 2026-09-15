class ProfilesController < ApplicationController
  def show
    @user = User.find_by!(handle: params[:handle])
    return head :not_found if @user.blocks?(current_user)

    @collections = @user.link_collections.includes(:product_links)
    @uncategorized_links = @user.product_links.where(link_collection_id: nil)
    @paid_media_posts = @user.paid_media_posts.published.order(created_at: :desc)
    @wishlists = @user.wishlists.where(published: true).includes(:wishlist_items)
    @contact_reveals = @user.contact_reveals.published.order(:created_at)
    @meet_offers = @user.meet_offers.published.includes(:meet_slots).order(:created_at)
    @creator_posts = @user.creator_posts.where(published: true).includes(:creator_post_likes, creator_post_comments: :user).order(created_at: :desc)
    @social_links = [
      [ "Instagram", @user.instagram_handle, "https://instagram.com/" ],
      [ "YouTube", @user.youtube_handle, "https://youtube.com/@" ],
      [ "X", @user.x_handle, "https://x.com/" ],
      [ "Reddit", @user.reddit_handle, "https://reddit.com/user/" ],
      [ "TikTok", @user.tiktok_handle, "https://tiktok.com/@" ]
    ].select { |link| link[1].present? }
  end
end
