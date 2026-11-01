class EventTracker
  # Async (default) — fire-and-forget via TrackEventJob. The HTTP response
  # is never blocked by an analytics INSERT.
  def self.track(action:, actor:, creator: nil, target: nil, properties: {}, request: nil, session_id: nil)
    actor_id   = actor.is_a?(User) ? actor.id : actor.to_i
    creator_id = creator.is_a?(User) ? creator.id : creator&.to_i

    meta = extract_request_meta(request)

    TrackEventJob.perform_later(
      actor_id: actor_id,
      action: action.to_s,
      creator_id: creator_id,
      target_type: target&.class&.name,
      target_id: target&.id,
      properties: (properties || {}).deep_stringify_keys,
      source: properties&.dig(:source) || properties&.dig("source") || "direct",
      referrer: meta[:referrer],
      device_type: meta[:device_type],
      ip_hash: meta[:ip_hash],
      session_id: session_id
    )

    # Fan profile update runs as its own async job
    if actor_id.present? && creator_id.present? && actor_id != creator_id
      FanProfileRecalculateJob.perform_later(actor_id, creator_id, action.to_s, (properties || {}).deep_stringify_keys)
    end
  end

  # Sync — for callbacks that need the Event record back immediately (e.g.,
  # follow-backfill, payment fulfillment).
  def self.track_sync(action:, actor:, creator: nil, target: nil, properties: {}, request: nil, session_id: nil)
    event = Event.track(
      action: action, actor: actor, creator: creator, target: target,
      properties: properties, request: request, session_id: session_id
    )

    if event&.actor_id.present? && event&.creator_id.present? && event.actor_id != event.creator_id
      FanProfileRecalculateJob.perform_later(event.actor_id, event.creator_id, event.action, (event.properties || {}).deep_stringify_keys)
    end
    event
  rescue StandardError => e
    Rails.logger.error("[EventTracker] sync track failed: #{e.message}")
    nil
  end

  private

  def self.extract_request_meta(request)
    return { device_type: "web", ip_hash: nil, referrer: nil } unless request

    ua = request.user_agent.to_s.downcase
    device_type = if ua.include?("wishful-pwa") || request.headers["X-Requested-With"] == "wishful-pwa"
                    "pwa"
                  elsif ua.include?("mobile") || ua.include?("android") || ua.include?("iphone")
                    "mobile_browser"
                  else
                    "desktop"
                  end
    ip_hash = request.remote_ip.present? ? Digest::SHA256.hexdigest(request.remote_ip.to_s)[0..15] : nil

    { device_type: device_type, ip_hash: ip_hash, referrer: request.referer }
  end
end

