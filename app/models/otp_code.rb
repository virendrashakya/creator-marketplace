# A six-digit sign-in code sent to a phone. Only a digest is stored, codes
# expire after ten minutes, and five wrong guesses burn the code, so a code
# cannot be brute-forced in its lifetime.
class OtpCode < ApplicationRecord
  TTL = 10.minutes
  MAX_ATTEMPTS = 5
  # How often a number may ask for a new code.
  RESEND_AFTER = 30.seconds

  validates :phone_number, :code_digest, :expires_at, presence: true

  scope :usable, -> { where(consumed_at: nil).where("expires_at > ?", Time.current).where("attempts < ?", MAX_ATTEMPTS) }

  # Returns [otp_record, plain_code]. The plain code exists only in memory long
  # enough to hand to the delivery channel.
  def self.issue!(phone_number, purpose: "sign_in")
    code = format("%06d", SecureRandom.random_number(1_000_000))
    record = create!(phone_number: phone_number, purpose: purpose,
                     code_digest: digest(phone_number, code), expires_at: TTL.from_now)
    [ record, code ]
  end

  def self.latest_for(phone_number)
    where(phone_number: phone_number).order(created_at: :desc).first
  end

  # True when the code is right. Every call, right or wrong, spends an attempt.
  def self.verify(phone_number, code)
    record = usable.where(phone_number: phone_number).order(created_at: :desc).first
    return false unless record

    record.increment!(:attempts)
    return false unless ActiveSupport::SecurityUtils.secure_compare(record.code_digest, digest(phone_number, code.to_s.gsub(/\D/, "")))

    record.update!(consumed_at: Time.current)
    true
  end

  def self.digest(phone_number, code)
    OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, "#{phone_number}:#{code}")
  end

  def resend_available_at
    created_at + RESEND_AFTER
  end
end
