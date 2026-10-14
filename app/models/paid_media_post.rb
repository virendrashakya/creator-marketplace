class PaidMediaPost < ApplicationRecord
  include MoneyFormatting

  belongs_to :user
  belongs_to :paid_media_collection, optional: true
  belongs_to :subscription_plan, optional: true
  has_many :media_purchases, dependent: :destroy
  has_one_attached :media
  has_one_attached :preview

  scope :published, -> { where(published: true) }

  validates :title, presence: true
  validates :media_type, inclusion: { in: %w[image video] }
  # The order items sit in inside a collection; the first one is the cover.
  scope :ordered, -> { order(:position, :id) }
  # Drops sold on their own, outside any collection.
  scope :standalone, -> { where(paid_media_collection_id: nil) }

  # An item inside a collection is sold by the collection, so it needs no
  # price of its own. A loose drop needs a price or a plan.
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :sellable
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
      (subscription_plan.present? && user.subscribed_to?(subscription_plan)) ||
      (paid_media_collection.present? && paid_media_collection.unlocked_for?(user))
  end

  # The cover of a collection is public, so it may be served unblurred.
  # Only once the collection is out: a draft's cover is still private.
  def collection_cover?
    paid_media_collection.present? && paid_media_collection.released? &&
      paid_media_collection.cover_post&.id == id
  end

  def price_label
    return money_label_for(price_cents) if price_cents.present?
    return paid_media_collection.price_label if paid_media_collection.present?

    subscription_plan&.name.presence || "Members only"
  end

  private

  def sellable
    return if price_cents.present? || subscription_plan_id.present? || paid_media_collection_id.present?

    errors.add(:price_cents, "or a plan is needed for a drop sold on its own")
  end

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
