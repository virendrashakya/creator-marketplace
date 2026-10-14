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

  # Phone numbers are stored as E.164. Indian numbers are what this app is
  # for, so a bare ten-digit number is read as +91.
  def self.normalize_phone(value)
    digits = value.to_s.gsub(/[^0-9]/, "")
    return nil if digits.blank?
    return "+91#{digits}" if digits.length == 10
    return "+#{digits}" if digits.length == 12 && digits.start_with?("91")

    "+#{digits}"
  end

  def self.find_by_phone(value)
    normalized = normalize_phone(value)
    normalized && find_by(phone_number: normalized)
  end

  has_many :link_lists, dependent: :destroy
  has_many :push_subscriptions, dependent: :destroy

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
    posts_heading:  "Feed & Updates",
    media_heading:  "The Vault: Exclusive Drops",
    links_heading:  "Curated Favs & Fits",
    meet_heading:   "1:1 Video Calls & Sessions",
    reveal_heading: "Private VIP Channels & Direct Access",
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

  RESERVED_HANDLES = %w[
    admin administrator support official wishful help security api assets
    dashboard creator_settings schedule lives conversations messages
    sign_in sign_up sign_out up rails cable pay root terms privacy
    about contact helpdesk billing checkout verified team
  ].freeze

  validates :name, presence: true
  # Email is optional for people who joined with a phone number, but an
  # account must carry at least one way to sign back in.
  validates :email, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :email, presence: true, if: -> { phone_number.blank? }
  validates :phone_number, uniqueness: true, format: { with: /\A\+[0-9]{10,15}\z/, message: "should be a valid mobile number" }, allow_blank: true
  validates :backup_upi_id, format: { with: UPI_ID_FORMAT, message: "should look like yourname@bank" }, allow_blank: true
  validates :auto_approve_under_cents, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :handle, presence: true, uniqueness: { case_sensitive: false },
                     format: { with: /\A[a-z0-9_]+\z/, message: "can use lowercase letters, numbers, and underscores" },
                     exclusion: { in: RESERVED_HANDLES, message: "is reserved by the platform" },
                     length: { minimum: 2, maximum: 30 }
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
    self.email = email.to_s.downcase.strip.presence
    self.phone_number = self.class.normalize_phone(phone_number) if phone_number.present?
    self.handle = handle.to_s.downcase.strip.delete_prefix("@")
  end

  public

  # Accounts created by OTP still need a password digest (the column and
  # has_secure_password both insist), but nobody is ever told this one: these
  # people sign in with a code.
  def assign_unusable_password
    self.password = SecureRandom.base58(32) if password_digest.blank?
  end

  def creator?
    account_type == "creator"
  end

  def first_name
    name.to_s.split.first
  end

  # The plan the storefront sells as "Close Friends": the cheapest active one.
  def close_friends_plan
    subscription_plans.where(active: true).order(:price_cents).first
  end

  def active_close_friends
    CreatorSubscription.joins(:subscription_plan)
                       .where(subscription_plans: { user_id: id }, status: "active")
                       .where("current_period_ends_at > ?", Time.current)
  end

  # Collections a fan can see right now: published and past their release.
  def live_collections
    paid_media_collections.live.order(created_at: :desc)
  end

  SOCIALS = [
    # key, label, column, url prefix (nil: the column holds a full URL)
    [ "instagram", "Instagram", :instagram_handle, "https://instagram.com/" ],
    [ "youtube",   "YouTube",   :youtube_handle,   "https://youtube.com/@" ],
    [ "website",   "Website",   :website_url,      nil ],
    [ "blog",      "Blog",      :blog_url,         nil ],
    [ "x",         "X",         :x_handle,         "https://x.com/" ],
    [ "tiktok",    "TikTok",    :tiktok_handle,    "https://tiktok.com/@" ],
    [ "reddit",    "Reddit",    :reddit_handle,    "https://reddit.com/user/" ]
  ].freeze

  # The socials this creator has filled in, ready to render. Website and blog
  # are shown without their scheme, the way people say them out loud.
  def social_links(only: nil)
    SOCIALS.filter_map do |key, label, column, prefix|
      value = public_send(column).to_s.strip
      next if value.blank?
      next if only && !only.include?(key)

      if prefix
        handle = value.delete_prefix("@").delete_prefix("u/")
        display = key == "youtube" ? "/#{handle}" : "@#{handle}"
        { key: key, label: label, display: display, url: "#{prefix}#{ERB::Util.url_encode(handle)}" }
      else
        url = value.match?(%r{\Ahttps?://}i) ? value : "https://#{value}"
        next if ProductLink.http_url_error(url)

        { key: key, label: label, display: value.sub(%r{\Ahttps?://}i, "").delete_suffix("/"), url: url }
      end
    end
  end

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
