# Async event tracking — offloads analytics writes from the request path.
# Every user action goes through this job so the HTTP response is never
# gated by a slow analytics INSERT.
class TrackEventJob < ApplicationJob
  queue_as :analytics

  # Retry once on transient DB errors, then discard. Analytics is
  # best-effort and must never block the queue.
  retry_on ActiveRecord::Deadlocked, wait: 2.seconds, attempts: 2
  discard_on ActiveRecord::RecordInvalid

  def perform(actor_id:, action:, creator_id: nil, target_type: nil, target_id: nil,
              properties: {}, source: nil, referrer: nil, device_type: nil, ip_hash: nil, session_id: nil)
    Event.create!(
      actor_id: actor_id,
      creator_id: creator_id,
      action: action.to_s,
      target_type: target_type,
      target_id: target_id,
      properties: properties || {},
      source: source || properties&.dig("source") || "direct",
      referrer: referrer,
      device_type: device_type || "web",
      ip_hash: ip_hash,
      session_id: session_id,
      created_at: Time.current
    )
  end
end
