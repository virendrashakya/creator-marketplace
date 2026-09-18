# A directional follow: `follower` follows `creator`. Both sides are users, so
# the columns are named for the role rather than the class.
class CreatorFollow < ApplicationRecord
  belongs_to :creator, class_name: "User", counter_cache: :followers_count
  belongs_to :follower, class_name: "User"

  validates :follower_id, uniqueness: { scope: :creator_id }
  validate :cannot_follow_self

  private

  def cannot_follow_self
    errors.add(:creator_id, "cannot be yourself") if creator_id.present? && creator_id == follower_id
  end
end
