class ContactReveal < ApplicationRecord
  belongs_to :user
  has_many :access_purchases, as: :purchasable, dependent: :destroy

  scope :published, -> { where(published: true) }

  validates :label, :secret_value, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, inclusion: { in: %w[INR USD] }

  # Single source of truth for who may see secret_value. The view must never
  # branch on anything else.
  def revealed_for?(other_user)
    return false if other_user.blank?
    return true if other_user == user
    return false if user.blocks?(other_user)

    access_purchases.exists?(buyer: other_user, status: "paid")
  end

  def price_label
    symbol = currency == "INR" ? "₹" : "$"
    "#{symbol}#{format('%.2f', price_cents.to_i / 100.0).sub(/\.00\z/, '')}"
  end
end
