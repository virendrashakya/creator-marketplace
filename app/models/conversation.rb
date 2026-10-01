class Conversation < ApplicationRecord
  belongs_to :creator, class_name: "User"
  belongs_to :fan, class_name: "User"
  has_many :direct_messages, dependent: :destroy

  # A thread with yourself is not a thread.
  validate :two_different_people

  scope :recent, -> { order(Arel.sql("last_message_at DESC NULLS LAST")) }

  # The one way to get a thread. Find-or-create rather than create, because
  # "Message" is a button a fan can press twice and there must only ever be
  # one thread per pair.
  def self.between(creator:, fan:)
    find_or_create_by!(creator: creator, fan: fan)
  end

  def participant?(user)
    user.present? && (user_id_matches?(creator_id, user) || user_id_matches?(fan_id, user))
  end

  def other_party(user)
    user == creator ? fan : creator
  end

  def unread_for(user)
    user == creator ? creator_unread_count : fan_unread_count
  end

  # Called after a message is created: bump activity, and add one unread for
  # whoever did not write it.
  def record_message!(message)
    recipient_column = message.sender_id == creator_id ? :fan_unread_count : :creator_unread_count
    self.class.where(id: id).update_all(
      [ "last_message_at = ?, #{recipient_column} = #{recipient_column} + 1, updated_at = ?",
       message.created_at, Time.current ]
    )
  end

  def mark_read_for!(user)
    column = user == creator ? :creator_unread_count : :fan_unread_count
    return unless participant?(user)

    update_column(column, 0)
  end

  private

  def user_id_matches?(id, user)
    id.present? && id == user.id
  end

  def two_different_people
    return if creator_id.blank? || fan_id.blank?
    return if creator_id != fan_id

    errors.add(:base, "A conversation needs two different people.")
  end
end
