class LiveMessagesController < ApplicationController
  before_action :require_user

  # The no-JS and catch-up path for live chat. The websocket is the normal
  # route, but a form post has to work too: a creator on a bad connection
  # should still be able to answer a question.
  def create
    @live = LiveSession.find(params[:live_session_id])
    @message = @live.live_messages.build(user: current_user, body: params[:body])

    if @message.save
      LiveChatChannel.broadcast_to(@live, {
        id: @message.id, body: @message.body,
        handle: current_user.handle, name: current_user.name,
        creator: @message.user_id == @live.user_id,
        at: @message.created_at.iso8601
      })
      redirect_to live_session_path(@live)
    else
      redirect_to live_session_path(@live), alert: @message.errors.full_messages.to_sentence
    end
  end

  # Catch-up after a dropped socket: everything newer than what the client
  # already has. Gated the same way the room is.
  def index
    @live = LiveSession.find(params[:live_session_id])
    return head :forbidden unless @live.watchable_by?(current_user)

    messages = @live.live_messages.after(params[:after]).chronological.limit(200)
    render json: messages.map { |m|
      { id: m.id, body: m.body, handle: m.user.handle, name: m.user.name,
        creator: m.user_id == @live.user_id, at: m.created_at.iso8601 }
    }
  end
end
