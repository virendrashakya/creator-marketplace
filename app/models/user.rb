class User < ApplicationRecord
  # e.g. "name@okhdfcbank" - handle@psp
  UPI_ID_FORMAT = /\A[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}\z/

  # The page-look choices, in one place so the settings screen, the inline
  # editor on the public page and the validation below cannot drift apart.
  # The two colours are only for the swatch a creator picks from; the real
  # tokens live in profile.css.
  #   value, label, swatch background, swatch dot
  THEME_CHOICES = [
    [ "minimal",    "Minimal",    "#F4F5F3", "#C2185B" ],
    [ "luxury",     "Luxury",     "#14142A", "#F0A9C8" ],
    [ "adventure",  "Adventure",  "#EDF1EA", "#0B5B42" ],
    [ "after_dark", "After dark", "#0C0D10", "#FF5C8A" ],
    [ "atelier",    "Atelier",    "#050505", "#E91E63" ]
  ].freeze
  THEMES = THEME_CHOICES.map(&:first).freeze

  LAYOUT_CHOICES = [
    [ "classic",   "List" ],
    [ "editorial", "Editorial" ],
    [ "gallery",   "Gallery" ]
  ].freeze
  LAYOUTS = LAYOUT_CHOICES.map(&:first).freeze

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
  has_many :live_sessions, dependent: :destroy
  has_many :live_messages, dependent: :destroy

  # Direct messages. A user is a creator in some threads and a fan in others,
  # so both sides are associations and `conversations` is the union.
  has_many :creator_conversations, class_name: "Conversation", foreign_key: :creator_id,
           dependent: :destroy, inverse_of: :creator
  has_many :fan_conversations, class_name: "Conversation", foreign_key: :fan_id,
           dependent: :destroy, inverse_of: :fan
  has_many :sent_direct_messages, class_name: "DirectMessage", foreign_key: :sender_id,
           dependent: :destroy, inverse_of: :sender
  has_many :creator_post_likes, dependent: :destroy
  has_many :creator_post_comments, dependent: :destroy
  has_many :creator_blocks, foreign_key: :creator_id, dependent: :destroy, inverse_of: :creator
  has_many :payment_claims, foreign_key: :claimant_id, dependent: :destroy, inverse_of: :claimant
  has_many :received_payment_claims, class_name: "PaymentClaim", foreign_key: :creator_id, dependent: :destroy, inverse_of: :creator

  # Follows, both directions. `followers_count` on users is a counter cache,
  # maintained by CreatorFollow, so the public profile never counts rows.
  has_many :follower_relationships, class_name: "CreatorFollow", foreign_key: :creator_id,
           dependent: :destroy, inverse_of: :creator
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, class_name: "CreatorFollow", foreign_key: :follower_id,
           dependent: :destroy, inverse_of: :follower
  has_many :following, through: :following_relationships, source: :creator

  # Section headings for the public page. Each falls back to a default, so a
  # creator who never opens settings still gets a page that reads well, and
  # one who wants their own voice can have it. The view asks the model rather
  # than hardcoding, which is what stops these drifting apart.
  SECTION_DEFAULTS = {
    posts_heading:  "Lately",
    media_heading:  "Behind the haul",
    links_heading:  "Things I recommend",
    meet_heading:   "Book me",
    reveal_heading: "Reach me directly",
    links_note:     "These are referral links. If you buy, the store pays a " \
                    "small cut at no extra cost to you."
  }.freeze

  SECTION_DEFAULTS.each_key do |field|
    define_method("#{field}_text") do
      public_send(field).presence || SECTION_DEFAULTS[field]
    end
  end

  def following?(creator)
    return false if creator.blank?
    following_relationships.exists?(creator_id: creator.id)
  end
  has_one_attached :profile_picture
  has_one_attached :banner
  has_one_attached :upi_qr

  before_validation :normalize_handle

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :handle, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[a-z0-9_]+\z/, message: "can use lowercase letters, numbers, and underscores" }, length: { maximum: 30 }
  validates :theme, inclusion: { in: THEMES }
  validates :profile_layout, inclusion: { in: LAYOUTS }
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

  # Active subscription to ANY of this creator's plans. What gates a
  # members-only live, where the question is "is this person a member",
  # not "which tier".
  def subscribed_to_creator?(creator)
    return false if creator.blank?

    creator_subscriptions
      .joins(:subscription_plan)
      .where(subscription_plans: { user_id: creator.id })
      .where(status: "active")
      .where("current_period_ends_at > ?", Time.current)
      .exists?
  end

  # Every thread this person is in, as a relation so callers can order and
  # paginate. Both sides are indexed with last_message_at, so the inbox's
  # ORDER BY is served by an index whichever side the row matches.
  def conversations
    Conversation.where(creator_id: id).or(Conversation.where(fan_id: id))
  end

  def total_unread_messages
    Conversation.where(creator_id: id).sum(:creator_unread_count) +
      Conversation.where(fan_id: id).sum(:fan_unread_count)
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
