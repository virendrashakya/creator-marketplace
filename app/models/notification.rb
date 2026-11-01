class Notification < ApplicationRecord
  KINDS = %w[
    claim_approved claim_rejected
    new_follower new_subscriber subscriber_renewed
    new_like new_comment new_message
    new_drop live_started
  ].freeze

  belongs_to :user
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :target, polymorphic: true, optional: true

  validates :kind, presence: true

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def mark_as_read!
    update_column(:read_at, Time.current) if read_at.nil?
  end

  def unread?
    read_at.nil?
  end
end
