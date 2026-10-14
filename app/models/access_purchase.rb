class AccessPurchase < ApplicationRecord
  belongs_to :buyer, class_name: "User"
  belongs_to :purchasable, polymorphic: true
  validates :status, inclusion: { in: %w[paid refunded] }

  scope :paid, -> { where(status: "paid") }
end
