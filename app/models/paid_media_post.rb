class PaidMediaPost < ApplicationRecord
  belongs_to :user
  belongs_to :paid_media_collection, optional: true
  belongs_to :subscription_plan, optional: true
  has_many :media_purchases, dependent: :destroy
  has_one_attached :media
  has_one_attached :preview

  scope :published, -> { where(published: true) }

  validates :title, presence: true
  validates :media_type, inclusion: { in: %w[image video] }
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }, unless: :subscription_plan_id?
  validates :subscription_plan, presence: true, if: -> { price_cents.blank? }
  validates :currency, inclusion: { in: %w[INR USD] }
  validate :media_attached
  validate :associations_belong_to_owner

  # The single source of truth for who may see the underlying file. Both the
  # profile card and the media streaming action ask this, so a rule change
  # lands in one place.
  def unlocked_for?(user)
    return false if user.blank?
    return true if user == self.user
    return false if self.user.blocks?(user)

    media_purchases.paid.exists?(buyer: user) ||
      (subscription_plan.present? && user.subscribed_to?(subscription_plan))
  end

  def price_label
    return subscription_plan&.name.presence || "Members only" if price_cents.blank?

    symbol = currency == "INR" ? "₹" : "$"
    "#{symbol}#{format('%.2f', price_cents / 100.0).sub(/\.00\z/, '')}"
  end

  private

  def media_attached
    errors.add(:media, "must be uploaded") unless media.attached?
  end

  # Guards against attaching another creator's plan or collection via mass
  # assignment, which would gate this post behind someone else's subscribers.
  def associations_belong_to_owner
    errors.add(:subscription_plan, "is not yours") if subscription_plan.present? && subscription_plan.user_id != user_id
    errors.add(:paid_media_collection, "is not yours") if paid_media_collection.present? && paid_media_collection.user_id != user_id
  end
end
