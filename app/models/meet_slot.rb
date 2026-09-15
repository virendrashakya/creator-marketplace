class MeetSlot < ApplicationRecord
  belongs_to :meet_offer
  has_one :meet_booking, dependent: :destroy

  validates :starts_at, :ends_at, presence: true
  validate :ends_after_start
  validate :does_not_overlap_another_slot

  scope :upcoming, -> { where(starts_at: Time.current..).order(:starts_at) }
  scope :bookable, -> { upcoming.where.missing(:meet_booking) }

  def booked?
    meet_booking.present?
  end

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, "must be after the start time") if ends_at <= starts_at
  end

  def does_not_overlap_another_slot
    return if starts_at.blank? || ends_at.blank? || meet_offer.blank?

    clash = meet_offer.meet_slots.where.not(id: id)
                      .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
    errors.add(:starts_at, "overlaps another slot") if clash.exists?
  end
end
