class ConversationsController < ApplicationController
  before_action :require_user

  # The inbox. Both sides of the app in one list: threads where you are the
  # creator and threads where you are the fan, because a creator is also
  # somebody else's fan.
  def index
    @conversations = current_user.conversations
                                .includes(:creator, :fan)
                                .recent
                                .limit(100)
  end

  def show
    @conversation = find_participating_conversation
    @other = @conversation.other_party(current_user)
    @messages = @conversation.direct_messages.includes(:sender).chronological.last(200)
    # Opening the thread is reading it.
    @conversation.mark_read_for!(current_user)
  end

  # Started from a creator's public page. find_or_create, so pressing
  # "Message" twice lands in the same thread rather than splitting history.
  def create
    creator = User.find_by!(handle: params[:handle])
    return head :not_found if creator.blocks?(current_user)
    if creator == current_user
      redirect_to conversations_path, alert: "You cannot message yourself." and return
    end

    conversation = Conversation.between(creator: creator, fan: current_user)
    redirect_to conversation_path(conversation)
  end

  private

  def find_participating_conversation
    conversation = Conversation.find(params[:id])
    # A thread you are not in is not yours to read. 404 rather than 403: the
    # existence of a thread between two other people is itself private.
    raise ActiveRecord::RecordNotFound unless conversation.participant?(current_user)

    conversation
  end
end
