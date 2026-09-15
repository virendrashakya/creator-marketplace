# Turns an approved PaymentClaim into the entitlement it was made for.
# Every revenue mechanic grants access through exactly one of these branches,
# so when a real gateway is added its webhook calls the same code.
class PaymentFulfillment
  class UnsupportedPurchasable < StandardError; end

  def initialize(claim)
    @claim = claim
  end

  def grant!
    case purchasable
    when PaidMediaPost      then unlock_media
    when SubscriptionPlan   then start_subscription
    when ContactReveal      then record_access_purchase
    when PaidMediaCollection then record_access_purchase
    when MeetSlot           then confirm_booking
    when WishlistItem       then record_gift
    else
      raise UnsupportedPurchasable, "cannot fulfill #{purchasable.class}"
    end
  end

  private

  attr_reader :claim

  def purchasable = claim.purchasable
  def buyer = claim.claimant
  def reference = "upi_#{claim.utr.presence || claim.id}"

  def unlock_media
    purchase = MediaPurchase.find_or_initialize_by(paid_media_post: purchasable, buyer: buyer)
    purchase.update!(amount_cents: claim.amount_cents, currency: claim.currency, status: "paid", payment_reference: reference)
  end

  def start_subscription
    subscription = CreatorSubscription.find_or_initialize_by(subscription_plan: purchasable, subscriber: buyer)
    # Extend from the existing expiry when still active, so an early renewal
    # does not lose the remaining days.
    base = [ subscription.current_period_ends_at, Time.current ].compact.max
    subscription.update!(status: "active", current_period_ends_at: base + 1.month, payment_reference: reference)
  end

  def record_access_purchase
    purchase = AccessPurchase.find_or_initialize_by(purchasable: purchasable, buyer: buyer)
    purchase.update!(amount_cents: claim.amount_cents, currency: claim.currency, status: "paid", payment_reference: reference)
  end

  def confirm_booking
    booking = MeetBooking.find_or_initialize_by(meet_slot: purchasable)
    raise ActiveRecord::RecordInvalid, booking if booking.persisted? && booking.attendee_id != buyer.id

    booking.update!(attendee: buyer, amount_cents: claim.amount_cents, currency: claim.currency, status: "paid", payment_reference: reference)
  end

  def record_gift
    purchasable.with_lock do
      GiftContribution.create!(
        wishlist_item: purchasable,
        giver: buyer,
        amount_cents: claim.amount_cents,
        message: claim.note.presence,
        status: "paid",
        payment_reference: reference
      )
      purchasable.refresh_funding_status!
    end
  end
end
