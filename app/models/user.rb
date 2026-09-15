class User < ApplicationRecord
  # e.g. "name@okhdfcbank" - handle@psp
  UPI_ID_FORMAT = /\A[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}\z/

  has_secure_password

  has_many :link_collections, dependent: :destroy
  has_many :product_links, dependent: :destroy
  has_many :paid_media_posts, dependent: :destroy
  has_many :media_purchases, foreign_key: :buyer_id, dependent: :destroy, inverse_of: :buyer
  has_many :paid_media_collections, dependent: :destroy
  has_many :subscription_plans, dependent: :destroy
  has_many :creator_subscriptions, foreign_key: :subscriber_id, dependent: :destroy, inverse_of: :subscriber
  has_many :access_purchases, foreign_key: :buyer_id, dependent: :destroy, inverse_of: :buyer
  has_many :contact_reveals, dependent: :destroy
  has_many :meet_offers, dependent: :destroy
  has_many :wishlists, dependent: :destroy
  has_many :gift_contributions, foreign_key: :giver_id, dependent: :destroy, inverse_of: :giver
  has_many :creator_posts, dependent: :destroy
  has_many :creator_post_likes, dependent: :destroy
  has_many :creator_post_comments, dependent: :destroy
  has_many :creator_blocks, foreign_key: :creator_id, dependent: :destroy, inverse_of: :creator
  has_many :payment_claims, foreign_key: :claimant_id, dependent: :destroy, inverse_of: :claimant
  has_many :received_payment_claims, class_name: "PaymentClaim", foreign_key: :creator_id, dependent: :destroy, inverse_of: :creator
  has_one_attached :profile_picture
  has_one_attached :banner
  has_one_attached :upi_qr

  before_validation :normalize_handle

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :handle, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[a-z0-9_]+\z/, message: "can use lowercase letters, numbers, and underscores" }, length: { maximum: 30 }
  validates :theme, inclusion: { in: %w[minimal luxury adventure after_dark] }
  validates :profile_layout, inclusion: { in: %w[classic editorial gallery] }
  validates :account_type, inclusion: { in: %w[creator personal business] }
  validates :upi_id, format: { with: UPI_ID_FORMAT, message: "should look like yourname@bank" }, allow_blank: true
  validate :upi_details_present_when_accepting

  private

  def upi_details_present_when_accepting
    return unless accepts_upi_manual?
    return if upi_id.present? || upi_qr.attached?

    errors.add(:base, "Add a UPI ID or upload a QR code before accepting payments.")
  end

  def normalize_handle
    self.email = email.to_s.downcase.strip
    self.handle = handle.to_s.downcase.strip.delete_prefix("@")
  end

  public

  def subscribed_to?(plan)
    creator_subscriptions.where(subscription_plan: plan, status: "active").where("current_period_ends_at > ?", Time.current).exists?
  end

  def blocks?(other_user)
    return false if other_user.blank? || other_user == self

    identifiers = [
      [ "username", other_user.handle.to_s.downcase ],
      [ "email", other_user.email.to_s.downcase ],
      [ "phone", other_user.phone_number.to_s.gsub(/[^0-9]/, "") ]
    ].reject { |_type, value| value.blank? }
    return false if identifiers.empty?

    clause = identifiers.map { "(identifier_type = ? AND identifier_value = ?)" }.join(" OR ")
    creator_blocks.where(clause, *identifiers.flatten).exists?
  end
end
