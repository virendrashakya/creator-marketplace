class DiscoverController < ApplicationController
  def index
    @trending_collections = PaidMediaCollection.live.order(unlocks_count: :desc, created_at: :desc).limit(12)
    @featured_creators = User.where(account_type: "creator").order(followers_count: :desc).limit(8)
    @upcoming_lives = LiveSession.visible.upcoming.limit(4)
    @categories = User.where.not(creator_category: [nil, ""]).distinct.pluck(:creator_category)

    if params[:category].present?
      @category_creators = User.where(account_type: "creator", creator_category: params[:category]).order(followers_count: :desc).limit(12)
    end

    respond_to do |format|
      format.html
      format.json do
        render json: {
          categories: @categories,
          trending_collections: @trending_collections.map { |c| serialize_collection(c) },
          featured_creators: @featured_creators.map { |u| serialize_creator(u) },
          upcoming_lives: @upcoming_lives.map { |l| serialize_live(l) }
        }
      end
    end
  end

  private

  def serialize_creator(c)
    {
      id: c.id,
      handle: c.handle,
      name: c.name,
      avatar_url: c.avatar_url,
      bio: c.bio,
      category: c.creator_category,
      followers_count: c.followers_count,
      is_following: current_user ? current_user.following?(c) : false
    }
  end

  def serialize_collection(c)
    cover = c.cover_post
    {
      id: c.id,
      title: c.title,
      price_cents: c.price_cents,
      currency: c.currency,
      creator_handle: c.user.handle,
      creator_name: c.user.name,
      category: c.user.creator_category,
      cover_preview_url: cover ? "/paid_media_posts/#{cover.id}/preview" : nil
    }
  end

  def serialize_live(l)
    {
      id: l.id,
      title: l.title,
      creator_handle: l.user.handle,
      creator_name: l.user.name,
      scheduled_for: l.scheduled_for,
      status: l.status,
      access: l.access
    }
  end
end
