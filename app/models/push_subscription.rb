# A browser's Web Push endpoint for one signed-in person. The installed PWA
# registers one; WebPushNotifier sends to every endpoint a user has.
class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, presence: true, uniqueness: true
  validates :p256dh, :auth, presence: true
  validate :endpoint_is_https

  private

  def endpoint_is_https
    errors.add(:endpoint, "must be https") unless endpoint.to_s.start_with?("https://")
  end
end
