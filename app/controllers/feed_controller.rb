class FeedController < ApplicationController
  before_action :require_user, only: %i[seen]

  def index
    if signed_in?
      @feed_items = current_user.feed_items.recent.includes(:creator).limit(30)

      # If the fan follows no one or feed is empty, provide suggested drops & creators
      if @feed_items.empty?
        @suggested_creators = User.where(account_type: "creator").where.not(id: current_user.id).order(followers_count: :desc).limit(6)
        @trending_collections = PaidMediaCollection.live.order(created_at: :desc).limit(6)
      end
    else
      # Guest browsing feed sees top trending collections and active creators
      @suggested_creators = User.where(account_type: "creator").order(followers_count: :desc).limit(6)
      @trending_collections = PaidMediaCollection.live.order(created_at: :desc).limit(10)
      @feed_items = []
    end

    respond_to do |format|
      format.html
      format.json do
        render json: {
          feed_items: @feed_items.map { |item| serialize_feed_item(item) },
          suggested_creators: @suggested_creators&.map { |c| serialize_creator(c) } || [],
          trending_collections: @trending_collections&.map { |c| serialize_collection(c) } || []
        }
      end
    end
  end

  def seen
    item = current_user.feed_items.find_by(id: params[:id])
    item&.mark_seen!
    head :ok
  end

  private

  def serialize_feed_item(item)
    target = item.target
    {
      id: item.id,
      item_type: item.item_type,
      published_at: item.published_at,
      seen: item.seen,
      score: item.score,
      creator: serialize_creator(item.creator),
      target: serialize_target(item.item_type, target)
    }
  end

  def serialize_creator(creator)
    return nil unless creator
    {
      id: creator.id,
      handle: creator.handle,
      name: creator.name,
      avatar_url: creator.avatar_url,
      bio: creator.bio,
      followers_count: creator.followers_count
    }
  end

  def serialize_collection(c)
    return nil unless c
    cover = c.cover_post
    {
      id: c.id,
      title: c.title,
      price_cents: c.price_cents,
      currency: c.currency,
      items_count: c.paid_media_posts.count,
      handle: c.user.handle,
      cover_image_url: cover.present? ? "/paid_media_posts/#{cover.id}/preview" : nil
    }
  end

  def serialize_target(type, target)
    return nil unless target
    case target
    when PaidMediaCollection
      serialize_collection(target)
    when CreatorPost
      {
        id: target.id,
        body: target.body,
        likes_count: target.likes_count,
        comments_count: target.comments_count,
        has_media: target.media.attached?,
        video: target.video?,
        paid_media_collection_id: target.paid_media_collection_id
      }
    when LiveSession
      {
        id: target.id,
        title: target.title,
        scheduled_for: target.scheduled_for,
        status: target.status,
        access: target.access
      }
    else
      { id: target.id }
    end
  end
end
