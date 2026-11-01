class FeedItem < ApplicationRecord
  ITEM_TYPES = %w[collection post live close_friends spoil_me].freeze

  belongs_to :fan, class_name: "User"
  belongs_to :creator, class_name: "User"
  belongs_to :target, polymorphic: true

  validates :item_type, presence: true, inclusion: { in: ITEM_TYPES }
  validates :published_at, presence: true
  validates :target_id, uniqueness: { scope: [:fan_id, :target_type], message: "already exists in fan feed" }

  scope :for_fan, ->(fan_id) { where(fan_id: fan_id).order(published_at: :desc) }
  scope :unseen, -> { where(seen: false) }
  scope :recent, -> { order(published_at: :desc) }

  def mark_seen!
    update_column(:seen, true) unless seen?
  end
end
