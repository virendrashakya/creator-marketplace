class LiveMessage < ApplicationRecord
  belongs_to :live_session, counter_cache: :live_messages_count
  belongs_to :user

  # Short, because this is chat in a moving room and a wall of text in a live
  # is noise for everyone watching.
  validates :body, presence: true, length: { maximum: 300 }
  # The paywall again, at the last gate. A controller check alone would let a
  # console or a replayed form write into a room the sender cannot watch.
  validate :sender_may_chat

  scope :chronological, -> { order(:id) }
  scope :after, ->(id) { where("live_messages.id > ?", id.to_i) }

  private

  def sender_may_chat
    return if live_session.blank? || user.blank?
    return if live_session.chattable_by?(user)

    errors.add(:base, "You cannot post in this live.")
  end
end
