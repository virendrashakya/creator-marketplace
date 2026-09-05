class WishlistItem < ApplicationRecord
  belongs_to :wishlist
  has_many :gift_contributions, dependent: :destroy
  validates :title, presence: true
  validates :target_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :status, inclusion: { in: %w[available funded gifted] }

  def raised_cents
    gift_contributions.where(status: "paid").sum(:amount_cents)
  end

  def remaining_cents
    [target_cents - raised_cents, 0].max
  end
end
