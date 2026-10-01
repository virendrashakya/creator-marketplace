# Chat inside a live. Public to everyone in the room, which is what makes it
# a different thing from a direct message.
#
# The paywall is checked on subscribe AND on every incoming message, because
# a subscription can lapse mid-broadcast and a socket that was authorised
# when it opened must not stay authorised forever.
class LiveChatChannel < ApplicationCable::Channel
  def subscribed
    live = LiveSession.find_by(id: params[:live_id])
    return reject if live.blank?
    # Watching is the right gate here rather than chatting: a member may
    # follow along in a room whose chat has closed.
    return reject unless live.watchable_by?(current_user)

    stream_for live
  end

  def speak(data)
    live = LiveSession.find_by(id: params[:live_id])
    return if live.blank?

    message = live.live_messages.build(user: current_user, body: data["body"].to_s)
    # The model re-checks chattable_by?, so a lapsed subscriber or a closed
    # room is refused here even though the socket is still open.
    return unless message.save

    LiveChatChannel.broadcast_to(live, payload_for(message))
  end

  private

  def payload_for(message)
    {
      id: message.id,
      body: message.body,
      handle: message.user.handle,
      name: message.user.name,
      creator: message.user_id == message.live_session.user_id,
      at: message.created_at.iso8601
    }
  end
end
