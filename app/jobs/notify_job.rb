# Async notification dispatch — creates an in-app notification record and
# optionally triggers Web Push. Runs off the request path so the fan's
# tap-to-like or comment submission stays snappy.
class NotifyJob < ApplicationJob
  queue_as :messaging

  discard_on ActiveRecord::RecordNotFound

  def perform(user_id:, kind:, actor_id: nil, target_type: nil, target_id: nil, data: {})
    # Deduplicate: don't notify yourself
    return if actor_id.present? && user_id == actor_id

    notification = Notification.create!(
      user_id: user_id,
      actor_id: actor_id,
      kind: kind,
      target_type: target_type,
      target_id: target_id,
      data: data
    )

    # Web Push for high-priority notifications
    user = User.find(user_id)
    actor = actor_id.present? ? User.find_by(id: actor_id) : nil
    actor_name = actor&.handle || "Someone"

    title, body = notification_copy(kind, actor_name, data)
    return unless title # Skip push for low-priority kinds

    WebPushNotifier.deliver(user, title: title, body: body, tag: "#{kind}-#{notification.id}")
  rescue StandardError => e
    Rails.logger.error("[NotifyJob] Failed: #{e.message}")
  end

  private

  def notification_copy(kind, actor_name, data)
    case kind
    when "new_like"
      ["@#{actor_name} liked your post", data["post_title"].to_s.truncate(60)]
    when "new_comment"
      ["@#{actor_name} commented", data["comment_preview"].to_s.truncate(80)]
    when "new_follower"
      ["@#{actor_name} started following you", "You have a new fan!"]
    when "new_subscriber"
      ["@#{actor_name} joined your VIP", data["plan_name"] || "Close Friends Pass"]
    when "new_message"
      ["@#{actor_name} sent you a message", data["message_preview"].to_s.truncate(80)]
    when "new_drop"
      ["New drop from @#{actor_name}", data["collection_title"].to_s.truncate(60)]
    when "live_started"
      ["@#{actor_name} is live now!", data["live_title"].to_s.truncate(60)]
    else
      nil # No push for this kind
    end
  end
end
