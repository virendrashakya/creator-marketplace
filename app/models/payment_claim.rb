class PaymentClaim < ApplicationRecord
  # A follower's assertion that they have paid out-of-band (currently UPI).
  # Nothing is granted until the creator approves: `approve!` is the single
  # place entitlement is created, which is where a real gateway's webhook will
  # eventually call in too.
  METHODS = %w[upi_manual].freeze
  STATUSES = %w[pending approved rejected].freeze
  # UPI/NEFT/IMPS references are 12 digits, but banks vary; allow 6-24
  # alphanumerics so a legitimate reference is never rejected outright.
  UTR_FORMAT = /\A[A-Za-z0-9]{6,24}\z/

  belongs_to :claimant, class_name: "User"
  belongs_to :creator, class_name: "User"
  belongs_to :purchasable, polymorphic: true
  belongs_to :reviewed_by, class_name: "User", optional: true
  has_one_attached :proof

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }
  scope :newest_first, -> { order(created_at: :desc) }

  validates :status, inclusion: { in: STATUSES }
  validates :payment_method, inclusion: { in: METHODS }
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :claimed_amount_cents, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :currency, inclusion: { in: %w[INR USD] }
  validates :note, length: { maximum: 300 }, allow_blank: true
  validates :utr, format: { with: UTR_FORMAT, message: "should be the 12-digit reference from your UPI app" }, allow_blank: true
  validate :utr_or_proof_present
  validate :claimant_is_not_creator

  before_validation :normalize_utr

  def pending? = status == "pending"
  def approved? = status == "approved"
  def rejected? = status == "rejected"

  # True when the follower says they paid a different amount than we asked for.
  def amount_mismatch?
    claimed_amount_cents.present? && claimed_amount_cents != amount_cents
  end

  def money_label(cents = amount_cents)
    symbol = currency == "INR" ? "₹" : "$"
    "#{symbol}#{format('%.2f', cents.to_i / 100.0).sub(/\.00\z/, '')}"
  end

  # Grants the entitlement the claim was made for. Wrapped in a transaction so
  # a failure to grant leaves the claim pending rather than silently approved.
  def approve!(reviewer)
    transaction do
      update!(status: "approved", reviewed_at: Time.current, reviewed_by: reviewer, reject_reason: nil)
      PaymentFulfillment.new(self).grant!
    end
  end

  def reject!(reviewer, reason = nil)
    update!(status: "rejected", reviewed_at: Time.current, reviewed_by: reviewer, reject_reason: reason.presence)
  end

  private

  def normalize_utr
    self.utr = utr.to_s.strip.upcase.presence
  end

  def utr_or_proof_present
    return if utr.present? || proof.attached?

    errors.add(:utr, "or a payment screenshot is required")
  end

  def claimant_is_not_creator
    errors.add(:claimant, "cannot pay themselves") if claimant_id.present? && claimant_id == creator_id
  end
end
