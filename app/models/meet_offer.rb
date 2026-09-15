class MeetOffer < ApplicationRecord
  belongs_to :user
  has_many :meet_slots, dependent: :destroy

  scope :published, -> { where(published: true) }

  validates :title, :location, presence: true
  validates :price_cents, :duration_minutes, numericality: { only_integer: true, greater_than: 0 }
  validates :currency, inclusion: { in: %w[INR USD] }

  def price_label
    symbol = currency == "INR" ? "₹" : "$"
    "#{symbol}#{format('%.2f', price_cents.to_i / 100.0).sub(/\.00\z/, '')}"
  end
end
