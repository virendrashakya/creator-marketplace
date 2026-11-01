# Moves conversation metadata updates off the HTTP request path.
# After a DM is saved and broadcast, this job:
#   1. Bumps last_message_at (already done in model callback, but this is the
#      notification half)
#   2. Fires a notification + Web Push to the recipient
#   3. Tracks the message_send event for analytics
class UpdateConversationJob < ApplicationJob
  queue_as :messaging

  discard_on ActiveRecord::RecordNotFound

  def perform(conversation_id, sender_id, message_preview: nil)
    convo = Conversation.find(conversation_id)
    sender = User.find(sender_id)
    recipient = convo.other_party(sender)

    # In-app notification
    NotifyJob.perform_later(
      user_id: recipient.id,
      kind: "new_message",
      actor_id: sender.id,
      target_type: "Conversation",
      target_id: convo.id,
      data: { "message_preview" => message_preview.to_s.truncate(80) }
    )

    # Analytics event
    EventTracker.track(
      action: "message_send",
      actor: sender,
      creator: convo.creator,
      target: convo
    )
  end
end
