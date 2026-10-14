# Web Push for the installed PWA.
#
# VAPID keys come from VAPID_PUBLIC_KEY / VAPID_PRIVATE_KEY. In development,
# when they are missing, a pair is generated once and kept in
# storage/vapid.json so subscriptions survive a server restart.
class WebPushNotifier
  def self.keys
    @keys ||= begin
      if ENV["VAPID_PUBLIC_KEY"].present? && ENV["VAPID_PRIVATE_KEY"].present?
        { public_key: ENV["VAPID_PUBLIC_KEY"], private_key: ENV["VAPID_PRIVATE_KEY"] }
      elsif Rails.env.local?
        path = Rails.root.join("storage", "vapid.json")
        if path.exist?
          JSON.parse(path.read).symbolize_keys
        else
          key = WebPush.generate_key
          pair = { public_key: key.public_key, private_key: key.private_key }
          path.write(pair.to_json)
          pair
        end
      end
    end
  end

  def self.enabled?
    keys.present?
  end

  def self.public_key
    keys&.dig(:public_key)
  end

  # Fire and forget: a dead endpoint is removed, any other failure is logged.
  # A push is a nicety on top of the in-app state, never the only record.
  def self.deliver(user, title:, body:, url: "/", tag: nil)
    return unless enabled?

    message = { title: title, body: body, url: url, tag: tag }.compact.to_json
    user.push_subscriptions.find_each do |sub|
      WebPush.payload_send(
        message: message, endpoint: sub.endpoint, p256dh: sub.p256dh, auth: sub.auth,
        vapid: { subject: "mailto:support@wishful.app", public_key: keys[:public_key], private_key: keys[:private_key] },
        ttl: 24 * 3600, urgency: "normal"
      )
    rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
      sub.destroy
    rescue StandardError => e
      Rails.logger.warn("[push] #{e.class}: #{e.message}")
    end
  end
end
