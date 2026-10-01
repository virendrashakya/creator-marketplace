class SubscriptionPlan < ApplicationRecord
  # Plans were the one paid thing without a price label, so every view
  # formatted their price itself and got Western grouping on rupees.
  include MoneyFormatting

  belongs_to :user
  has_many :creator_subscriptions, dependent: :destroy
  has_many :paid_media_posts, dependent: :nullify
  has_many :paid_media_collections, dependent: :nullify
  validates :name, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }

  def price_label
    money_label_for(price_cents)
  end
end
