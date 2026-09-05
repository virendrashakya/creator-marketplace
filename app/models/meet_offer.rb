class MeetOffer < ApplicationRecord
  belongs_to :user
  has_many :meet_slots, dependent: :destroy
  validates :title, :location, presence: true
  validates :price_cents, :duration_minutes, numericality: { only_integer: true, greater_than: 0 }
end
