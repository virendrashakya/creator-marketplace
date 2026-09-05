class GiftContribution < ApplicationRecord
  belongs_to :wishlist_item
  belongs_to :giver, class_name: "User"
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
end
