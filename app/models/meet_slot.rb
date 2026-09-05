class MeetSlot < ApplicationRecord
  belongs_to :meet_offer
  has_one :meet_booking, dependent: :destroy
  validates :starts_at, :ends_at, presence: true
end
