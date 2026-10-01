class DirectMessagesController < ApplicationController
  before_action :require_user

  def create
    conversation = Conversation.find(params[:conversation_id])
    raise ActiveRecord::RecordNotFound unless conversation.participant?(current_user)

    # A creator who blocked this fan should stop receiving their messages.
    other = conversation.other_party(current_user)
    return if deny_if_blocked_by(other)

    message = conversation.direct_messages.build(sender: current_user, body: params[:body])
    if message.save
      ConversationChannel.broadcast_to(conversation, {
        id: message.id, body: message.body, sender_id: message.sender_id,
        handle: current_user.handle, at: message.created_at.iso8601
      })
      redirect_to conversation_path(conversation)
    else
      redirect_to conversation_path(conversation), alert: message.errors.full_messages.to_sentence
    end
  end

  # Catch-up after a dropped socket.
  def index
    conversation = Conversation.find(params[:conversation_id])
    raise ActiveRecord::RecordNotFound unless conversation.participant?(current_user)

    messages = conversation.direct_messages.after(params[:after]).includes(:sender).chronological.limit(200)
    render json: messages.map { |m|
      { id: m.id, body: m.body, sender_id: m.sender_id, handle: m.sender.handle,
        at: m.created_at.iso8601 }
    }
  end
end
