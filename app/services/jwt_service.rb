class JwtService
  SECRET = Rails.application.secret_key_base

  def self.encode(user, exp: 30.days.from_now)
    payload = {
      sub: user.id,
      handle: user.handle,
      account_type: user.account_type,
      exp: exp.to_i,
      iat: Time.current.to_i
    }
    JWT.encode(payload, SECRET, "HS256")
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET, true, algorithm: "HS256")
    decoded.first
  rescue JWT::DecodeError => e
    Rails.logger.warn("[JwtService] Decode error: #{e.message}")
    nil
  end
end
