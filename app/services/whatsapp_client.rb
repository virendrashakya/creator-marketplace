require "net/http"

# Sends WhatsApp messages through the WhatsApp Business Cloud API.
#
# Business-initiated WhatsApp messages must use a pre-approved template, so
# every send here is a template send. Configure with:
#
#   WHATSAPP_TOKEN            permanent access token
#   WHATSAPP_PHONE_NUMBER_ID  the sending number's id
#   WHATSAPP_OTP_TEMPLATE     an "authentication" template with one {{1}}
#   WHATSAPP_NOTICE_TEMPLATE  a "utility" template with one {{1}} body param
#
# With none of that set (development, test, a fresh checkout) nothing leaves
# the machine: the message is written to the Rails log instead, which is how
# a developer reads their own sign-in code.
class WhatsappClient
  API = "https://graph.facebook.com/v20.0"

  def self.configured?
    ENV["WHATSAPP_TOKEN"].present? && ENV["WHATSAPP_PHONE_NUMBER_ID"].present?
  end

  def self.send_otp(phone, code)
    unless configured? && ENV["WHATSAPP_OTP_TEMPLATE"].present?
      Rails.logger.info("[whatsapp:log] OTP for #{phone}: #{code}")
      return :logged
    end

    deliver(phone, ENV["WHATSAPP_OTP_TEMPLATE"], [ code ], otp: true)
  end

  def self.send_notice(phone, text)
    return if phone.blank?

    unless configured? && ENV["WHATSAPP_NOTICE_TEMPLATE"].present?
      Rails.logger.info("[whatsapp:log] to #{phone}: #{text}")
      return :logged
    end

    deliver(phone, ENV["WHATSAPP_NOTICE_TEMPLATE"], [ text.truncate(900) ])
  end

  def self.deliver(phone, template, params, otp: false)
    components = [ { type: "body", parameters: params.map { |p| { type: "text", text: p.to_s } } } ]
    # Authentication templates carry the code a second time on their
    # copy-code button.
    components << { type: "button", sub_type: "url", index: "0", parameters: [ { type: "text", text: params.first.to_s } ] } if otp

    payload = {
      messaging_product: "whatsapp",
      to: phone.delete_prefix("+"),
      type: "template",
      template: { name: template, language: { code: "en" }, components: components }
    }

    uri = URI("#{API}/#{ENV["WHATSAPP_PHONE_NUMBER_ID"]}/messages")
    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json",
                                       "Authorization" => "Bearer #{ENV["WHATSAPP_TOKEN"]}")
    request.body = payload.to_json
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) { |http| http.request(request) }
    Rails.logger.warn("[whatsapp] #{response.code} #{response.body.to_s.truncate(300)}") unless response.is_a?(Net::HTTPSuccess)
    response.is_a?(Net::HTTPSuccess)
  rescue StandardError => e
    Rails.logger.error("[whatsapp] send failed: #{e.class} #{e.message}")
    false
  end
end
