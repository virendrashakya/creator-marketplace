class MediaPurchase < ApplicationRecord
  belongs_to :paid_media_post
  belongs_to :buyer, class_name: "User"

  validates :status, inclusion: { in: %w[pending paid refunded] }
  validates :buyer_id, uniqueness: { scope: :paid_media_post_id, message: "has already purchased this post" }

  scope :paid, -> { where(status: "paid") }
end
