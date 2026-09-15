class PaidMediaCollection < ApplicationRecord
  belongs_to :user
  belongs_to :subscription_plan, optional: true
  has_many :paid_media_posts, dependent: :nullify
  has_many :access_purchases, as: :purchasable, dependent: :destroy

  scope :published, -> { where(published: true) }

  validates :title, presence: true
  validates :price_cents, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :currency, inclusion: { in: %w[INR USD] }
  validate :subscription_plan_belongs_to_owner

  private

  def subscription_plan_belongs_to_owner
    errors.add(:subscription_plan, "is not yours") if subscription_plan.present? && subscription_plan.user_id != user_id
  end
end
