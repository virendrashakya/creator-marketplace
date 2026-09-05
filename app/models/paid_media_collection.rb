class PaidMediaCollection < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_plan, optional: true
  has_many :paid_media_posts, dependent: :nullify
  has_many :access_purchases, as: :purchasable, dependent: :destroy
  validates :title, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
