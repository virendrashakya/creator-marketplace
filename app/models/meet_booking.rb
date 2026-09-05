class MeetBooking < ApplicationRecord
  belongs_to :meet_slot
  belongs_to :attendee, class_name: "User"
end
