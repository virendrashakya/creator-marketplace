class FanProfile < ApplicationRecord
  TIERS = %w[lurker casual regular super_fan whale].freeze

  belongs_to :fan, class_name: "User"
  belongs_to :creator, class_name: "User"

  validates :fan_id, uniqueness: { scope: :creator_id, message: "already has a profile with this creator" }
  validates :tier, inclusion: { in: TIERS }

  scope :top_spenders, ->(limit = 10) { order(total_spent_cents: :desc).limit(limit) }
  scope :top_engaged, ->(limit = 10) { order(engagement_score: :desc).limit(limit) }
  scope :by_tier, ->(tier) { where(tier: tier) }
  scope :close_friends, -> { where(is_close_friend: true) }

  def recalculate_score!
    # Weighted composite scoring:
    # ₹1 spent = 3 points
    # Each unlock = 50 points
    # Each Close Friend month = 100 points
    # Likes = 2 points
    # Comments = 5 points
    # Messages = 3 points
    # Shares = 10 points
    # Live watches = 8 points
    # Gifts (₹1) = 5 points
    computed = ((total_spent_cents / 100.0) * 3).round +
               (collections_owned * 50) +
               (months_subscribed * 100) +
               (likes_given * 2) +
               (comments_given * 5) +
               (messages_sent * 3) +
               (shares_made * 10) +
               (live_watches * 8) +
               (((gifts_given_cents || 0) / 100.0) * 5).round

    new_tier = case computed
               when 0..49      then "lurker"
               when 50..199    then "casual"
               when 200..999   then "regular"
               when 1000..4999 then "super_fan"
               else                 "whale"
               end

    update_columns(engagement_score: computed, tier: new_tier, updated_at: Time.current)
  end

  def total_spent
    total_spent_cents / 100.0
  end
end
