# The thing fans buy. A collection's cover (its first item by position) is
# public; everything else in it stays hidden until the fan unlocks the whole
# collection, either by paying its price or by being in the plan it is
# included with (Close Friends).
class PaidMediaCollection < ApplicationRecord
  include MoneyFormatting

  belongs_to :user
  belongs_to :subscription_plan, optional: true
  has_many :paid_media_posts, -> { order(:position, :id) }, dependent: :nullify
  has_many :access_purchases, as: :purchasable, dependent: :destroy
  has_many :creator_posts, dependent: :nullify
  has_many :link_list_items, dependent: :destroy

  scope :published, -> { where(published: true) }
  # What a fan may see: published, and not scheduled for later.
  scope :live, -> { published.where("release_at IS NULL OR release_at <= ?", Time.current) }

  validates :title, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :currency, inclusion: { in: %w[INR USD] }
  validate :subscription_plan_belongs_to_owner
  validate :sellable

  def cover_post
    paid_media_posts.first
  end

  # Everything after the cover. The hidden part of the collection.
  def hidden_posts
    paid_media_posts.offset(1)
  end

  def released?
    published? && (release_at.nil? || release_at <= Time.current)
  end

  def scheduled?
    published? && release_at.present? && release_at > Time.current
  end

  def status_label
    return "Draft" unless published?
    return "Scheduled" if scheduled?

    "Live"
  end

  def unlocked_for?(viewer)
    return false if viewer.blank?
    return true if viewer.id == user_id
    return false if user.blocks?(viewer)

    access_purchases.paid.exists?(buyer: viewer) ||
      (subscription_plan.present? && viewer.subscribed_to?(subscription_plan))
  end

  def items_count
    paid_media_posts.size
  end

  def photos_count
    paid_media_posts.to_a.count { |p| p.media_type == "image" }
  end

  def videos_count
    paid_media_posts.to_a.count { |p| p.media_type == "video" }
  end

  # "16 photos · 2 reels"
  def contents_label
    parts = []
    parts << "#{photos_count} #{"photo".pluralize(photos_count)}" if photos_count.positive?
    parts << "#{videos_count} #{"reel".pluralize(videos_count)}" if videos_count.positive?
    parts.presence&.join(" · ") || "Empty"
  end

  def price_label
    return money_label_for(price_cents) if price_cents.present?

    subscription_plan.present? ? "Close Friends" : "Free"
  end

  def unlocks_count
    access_purchases.paid.count
  end

  def revenue_cents
    access_purchases.paid.sum(:amount_cents)
  end

  private

  def subscription_plan_belongs_to_owner
    errors.add(:subscription_plan, "is not yours") if subscription_plan.present? && subscription_plan.user_id != user_id
  end

  # A collection with neither a price nor a plan cannot be unlocked by anyone,
  # which would leave everything after the cover hidden for good.
  def sellable
    return if price_cents.present? || subscription_plan_id.present?

    errors.add(:price_cents, "or Close Friends is needed so fans can unlock it")
  end
end
