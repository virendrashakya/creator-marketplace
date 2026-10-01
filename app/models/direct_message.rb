class DirectMessage < ApplicationRecord
  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  validates :body, presence: true, length: { maximum: 2_000 }
  validate :sender_is_a_participant

  after_create_commit :touch_conversation

  scope :chronological, -> { order(:id) }
  scope :after, ->(id) { where("direct_messages.id > ?", id.to_i) }

  private

  def sender_is_a_participant
    return if conversation.blank? || sender.blank?
    return if conversation.participant?(sender)

    errors.add(:base, "You are not part of this conversation.")
  end

  # The inbox orders by last activity and shows an unread count, both of
  # which are denormalised onto the conversation. Doing it here rather than
  # in the controller means a message created anywhere keeps them true.
  def touch_conversation
    conversation.record_message!(self)
  end
end
