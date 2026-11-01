# A directional follow: `follower` follows `creator`. Both sides are users, so
# the columns are named for the role rather than the class.
class CreatorFollow < ApplicationRecord
  belongs_to :creator, class_name: "User", counter_cache: :followers_count
  belongs_to :follower, class_name: "User"

  validates :follower_id, uniqueness: { scope: :creator_id }
  validate :cannot_follow_self

  after_create_commit :track_follow_and_backfill_feed
  after_destroy_commit :purge_from_feed

  private

  def track_follow_and_backfill_feed
    EventTracker.track_sync(action: "follow", actor: follower, creator: creator)

    # Notify creator of new follower
    NotifyJob.perform_later(
      user_id: creator_id, kind: "new_follower", actor_id: follower_id,
      target_type: "CreatorFollow", target_id: id
    )

    # Backfill creator's last 5 collections and posts into the new follower's feed
    recent_collections = creator.paid_media_collections.live.order(created_at: :desc).limit(5)
    recent_collections.each do |c|
      FeedItem.find_or_create_by(
        fan_id: follower_id,
        creator_id: creator_id,
        item_type: "collection",
        target_type: "PaidMediaCollection",
        target_id: c.id
      ) do |item|
        item.published_at = c.release_at || c.created_at
        item.score = 2.0
      end
    end

    recent_posts = creator.creator_posts.where(published: true).order(created_at: :desc).limit(5)
    recent_posts.each do |p|
      FeedItem.find_or_create_by(
        fan_id: follower_id,
        creator_id: creator_id,
        item_type: "post",
        target_type: "CreatorPost",
        target_id: p.id
      ) do |item|
        item.published_at = p.created_at
        item.score = 0.0
      end
    end
  end

  def purge_from_feed
    FeedItem.where(fan_id: follower_id, creator_id: creator_id).delete_all
    EventTracker.track_sync(action: "unfollow", actor: follower, creator: creator)
  end

  def cannot_follow_self
    errors.add(:creator_id, "cannot be yourself") if creator_id.present? && creator_id == follower_id
  end
end
