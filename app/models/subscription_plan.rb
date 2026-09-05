class SubscriptionPlan < ApplicationRecord
  belongs_to :user
  has_many :creator_subscriptions, dependent: :destroy
  has_many :paid_media_posts, dependent: :nullify
  has_many :paid_media_collections, dependent: :nullify
  validates :name, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }
end
