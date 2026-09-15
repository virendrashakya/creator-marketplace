class MeetBooking < ApplicationRecord
  belongs_to :meet_slot
  belongs_to :attendee, class_name: "User"

  validates :status, inclusion: { in: %w[pending paid canceled refunded] }
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }

  scope :paid, -> { where(status: "paid") }
end
