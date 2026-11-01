class UserSession < ApplicationRecord
  belongs_to :user, optional: true

  validates :session_token, presence: true, uniqueness: true

  scope :active, -> { where(revoked_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  before_validation :ensure_session_token, on: :create

  def revoke!
    update_column(:revoked_at, Time.current)
  end

  def touch_last_seen!
    update_column(:last_seen_at, Time.current)
  end

  def active?
    revoked_at.nil? && (expires_at.nil? || expires_at > Time.current)
  end

  private

  def ensure_session_token
    self.session_token ||= SecureRandom.hex(32)
  end
end
