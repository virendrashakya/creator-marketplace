class PaidMediaPost < ApplicationRecord
  belongs_to :user
  belongs_to :paid_media_collection, optional: true
  belongs_to :subscription_plan, optional: true
  has_many :media_purchases, dependent: :destroy
  has_one_attached :media
  has_one_attached :preview

  validates :title, presence: true
  validates :media_type, inclusion: { in: %w[image video] }
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }, unless: :subscription_plan_id?
  validates :subscription_plan, presence: true, if: -> { price_cents.blank? }
  validates :currency, inclusion: { in: %w[INR USD] }
  validate :media_attached

  def price_label
    symbol = currency == "INR" ? "₹" : "$"
    "#{symbol}#{format('%.2f', price_cents / 100.0).sub(/\.00\z/, '')}"
  end

  private

  def media_attached
    errors.add(:media, "must be uploaded") unless media.attached?
  end
end
