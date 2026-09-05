class User < ApplicationRecord
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
  has_one_attached :profile_picture
  has_one_attached :banner

  before_validation :normalize_handle

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :handle, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[a-z0-9_]+\z/, message: "can use lowercase letters, numbers, and underscores" }, length: { maximum: 30 }
  validates :theme, inclusion: { in: %w[minimal luxury adventure after_dark] }
  validates :profile_layout, inclusion: { in: %w[classic editorial gallery] }
  validates :account_type, inclusion: { in: %w[creator personal business] }

  private

  def normalize_handle
    self.email = email.to_s.downcase.strip
    self.handle = handle.to_s.downcase.strip.delete_prefix("@")
  end

  public

  def subscribed_to?(plan)
    creator_subscriptions.where(subscription_plan: plan, status: "active").where("current_period_ends_at > ?", Time.current).exists?
  end

  def blocks?(other_user)
    return false unless other_user

    creator_blocks.exists?(identifier_type: "username", identifier_value: other_user.handle.downcase) ||
      creator_blocks.exists?(identifier_type: "email", identifier_value: other_user.email.downcase) ||
      (other_user.phone_number.present? && creator_blocks.exists?(identifier_type: "phone", identifier_value: other_user.phone_number.gsub(/\D/, "")))
  end
end
