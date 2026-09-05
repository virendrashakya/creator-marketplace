class ContactReveal < ApplicationRecord
  belongs_to :user
  has_many :access_purchases, as: :purchasable, dependent: :destroy
  validates :label, :secret_value, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }
end
