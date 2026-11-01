class FeedFanoutJob < ApplicationJob
  queue_as :analytics

  def perform(target_type, target_id, item_type)
    target = target_type.constantize.find_by(id: target_id)
    return unless target

    creator = case target
              when PaidMediaCollection then target.user
              when CreatorPost then target.user
              when LiveSession then target.user
              else target.try(:user)
              end
    return unless creator

    follower_ids = creator.follower_relationships.pluck(:follower_id)
    return if follower_ids.empty?

    published_at = target.try(:release_at) || target.try(:scheduled_for) || target.created_at
    now = Time.current

    score = compute_score(item_type, target)

    records = follower_ids.map do |fan_id|
      {
        fan_id: fan_id,
        creator_id: creator.id,
        item_type: item_type.to_s,
        target_type: target_type,
        target_id: target_id,
        score: score,
        seen: false,
        published_at: published_at,
        created_at: now
      }
    end

    # Batch insert with ignore duplicates
    records.each_slice(1000) do |slice|
      FeedItem.insert_all(slice, unique_by: :idx_feed_fan_target_unique)
    end
  end

  private

  def compute_score(item_type, target)
    base = 0.0

    case item_type.to_s
    when "collection", "collection_drop"
      base += 2.0
      base += 1.0 if target.try(:price_cents) && target.price_cents <= 29900
    when "live_now"
      base += 5.0
    when "live", "live_announcement"
      base += 1.0
    when "close_friends", "close_friends_promo"
      base += 0.5
    when "post"
      base += 0.0
      base += 0.5 if target.try(:paid_media_collection_id).present?
    end

    base
  end
end
