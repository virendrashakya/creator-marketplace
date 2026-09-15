class PaymentClaimsController < ApplicationController
  before_action :require_user

  PURCHASABLES = {
    "PaidMediaPost" => -> { PaidMediaPost.published },
    "PaidMediaCollection" => -> { PaidMediaCollection.published },
    "SubscriptionPlan" => -> { SubscriptionPlan.where(active: true) },
    "ContactReveal" => -> { ContactReveal.published },
    "MeetSlot" => -> { MeetSlot.all },
    "WishlistItem" => -> { WishlistItem.all }
  }.freeze

  # Follower-facing: shows the creator's UPI details and the claim form.
  def new
    @purchasable = find_purchasable
    @creator = creator_for(@purchasable)
    return redirect_to(root_path, alert: "This creator is not accepting payments right now.") unless @creator.accepts_upi_manual?
    return if deny_if_blocked_by(@creator)
    return redirect_to(profile_path(@creator.handle), alert: "You cannot pay yourself.") if @creator == current_user

    @amount_cents = amount_for(@purchasable)
    @payment_claim = PaymentClaim.new(claimed_amount_cents: @amount_cents)
  end

  def create
    @purchasable = find_purchasable
    @creator = creator_for(@purchasable)
    return redirect_to(root_path, alert: "This creator is not accepting payments right now.") unless @creator.accepts_upi_manual?
    return if deny_if_blocked_by(@creator)
    return redirect_to(profile_path(@creator.handle), alert: "You cannot pay yourself.") if @creator == current_user

    @amount_cents = amount_for(@purchasable)
    @payment_claim = PaymentClaim.new(claim_params)
    @payment_claim.assign_attributes(
      claimant: current_user,
      creator: @creator,
      purchasable: @purchasable,
      amount_cents: @amount_cents,
      currency: currency_for(@purchasable),
      payment_method: "upi_manual",
      status: "pending"
    )

    if @payment_claim.save
      redirect_to profile_path(@creator.handle), notice: "Payment submitted. #{@creator.name} will confirm it shortly."
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to profile_path(@creator.handle), alert: "That reference number has already been submitted."
  end

  # Creator-facing review queue.
  def index
    @pending_claims = current_user.received_payment_claims.pending.newest_first.includes(:claimant, :purchasable)
    @reviewed_claims = current_user.received_payment_claims.where.not(status: "pending").newest_first.limit(25).includes(:claimant, :purchasable)
  end

  def approve
    claim = current_user.received_payment_claims.pending.find(params[:id])
    claim.approve!(current_user)
    redirect_to payment_claims_path, notice: "Payment approved — access granted to @#{claim.claimant.handle}."
  rescue ActiveRecord::RecordInvalid, PaymentFulfillment::UnsupportedPurchasable => e
    redirect_to payment_claims_path, alert: "Could not grant access: #{e.message}"
  end

  def reject
    claim = current_user.received_payment_claims.pending.find(params[:id])
    claim.reject!(current_user, params[:reject_reason])
    redirect_to payment_claims_path, notice: "Payment rejected."
  end

  private

  def find_purchasable
    scope = PURCHASABLES.fetch(params[:purchasable_type]) { raise ActiveRecord::RecordNotFound }
    scope.call.find(params[:purchasable_id])
  end

  def creator_for(record)
    record.is_a?(MeetSlot) ? record.meet_offer.user : (record.try(:user) || record.wishlist.user)
  end

  def amount_for(record)
    case record
    when MeetSlot then record.meet_offer.price_cents
    when WishlistItem then record.remaining_cents
    else record.price_cents
    end
  end

  def currency_for(record)
    record.is_a?(MeetSlot) ? record.meet_offer.currency : record.currency
  end

  def claim_params
    params.require(:payment_claim).permit(:utr, :note, :claimed_amount_cents, :proof)
  end
end
