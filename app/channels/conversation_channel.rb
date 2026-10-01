# A direct message thread. Unlike live chat this is private to exactly two
# people, so the gate is participation rather than a subscription.
class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find_by(id: params[:conversation_id])
    return reject if conversation.blank?
    return reject unless conversation.participant?(current_user)

    stream_for conversation
  end

  def speak(data)
    conversation = Conversation.find_by(id: params[:conversation_id])
    return if conversation.blank? || !conversation.participant?(current_user)

    message = conversation.direct_messages.build(sender: current_user, body: data["body"].to_s)
    return unless message.save

    ConversationChannel.broadcast_to(conversation, {
      id: message.id,
      body: message.body,
      sender_id: message.sender_id,
      handle: message.sender.handle,
      at: message.created_at.iso8601
    })
  end
end
