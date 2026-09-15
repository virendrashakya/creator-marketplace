class WishlistItem < ApplicationRecord
  belongs_to :wishlist
  has_many :gift_contributions, dependent: :destroy

  validates :title, presence: true
  validates :target_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :status, inclusion: { in: %w[available funded gifted] }
  validates :currency, inclusion: { in: %w[INR USD] }
  validate :urls_are_public_http

  def raised_cents
    gift_contributions.paid.sum(:amount_cents)
  end

  def remaining_cents
    [ target_cents.to_i - raised_cents, 0 ].max
  end

  def funded?
    remaining_cents.zero?
  end

  def open_for_gifts?
    status == "available" && !funded?
  end

  def money_label(cents)
    symbol = currency == "INR" ? "₹" : "$"
    "#{symbol}#{format('%.2f', cents.to_i / 100.0).sub(/\.00\z/, '')}"
  end

  # Recomputed from the contributions rather than incremented, so it stays
  # correct no matter how gifts interleave.
  def refresh_funding_status!
    update!(status: "funded") if status == "available" && funded?
  end

  private

  # Same rule as ProductLink: these are creator-supplied and rendered to the public.
  def urls_are_public_http
    { product_url: product_url, image_url: image_url }.each do |field, value|
      next if value.blank?

      message = ProductLink.http_url_error(value)
      errors.add(field, message) if message
    end
  end
end
