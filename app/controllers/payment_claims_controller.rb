require "csv"

class PaymentClaimsController < ApplicationController
  # A fan never signs up up-front. They meet the account step only when they
  # pay, and land straight back here afterwards.
  before_action :require_payer, only: %i[new create]
  before_action :require_user, except: %i[new create]

  PURCHASABLES = {
    "PaidMediaPost" => -> { PaidMediaPost.published },
    "PaidMediaCollection" => -> { PaidMediaCollection.live },
    "SubscriptionPlan" => -> { SubscriptionPlan.where(active: true) },
    "ContactReveal" => -> { ContactReveal.published },
    "MeetSlot" => -> { MeetSlot.all },
    "WishlistItem" => -> { WishlistItem.all }
  }.freeze

  # 3f. The pay sheet: four UPI apps, the UPI ID and QR, then the UTR.
  def new
    load_purchase
    return if performed?

    @payment_claim = PaymentClaim.new(claimed_amount_cents: @amount_cents)
  end

  def create
    load_purchase
    return if performed?

    @payment_claim = PaymentClaim.new(claim_params)
    @payment_claim.assign_attributes(
      claimant: current_user,
      creator: @creator,
      purchasable: @purchasable,
      amount_cents: @amount_cents,
      currency: currency_for(@purchasable),
      payment_method: "upi_manual",
      status: "pending",
      link_list: @creator.link_lists.find_by(id: params[:list])
    )
    # What the fan says actually left their account. Usually the price; when
    # they tell us otherwise, the creator sees the mismatch flagged.
    paid = params[:paid_rupees].to_s.gsub(/[^0-9.]/, "")
    @payment_claim.claimed_amount_cents = paid.present? ? (paid.to_f * 100).round : @amount_cents

    if @payment_claim.save
      if @payment_claim.auto_approvable?
        @payment_claim.approve!(@creator)
      else
        Notifier.claim_created(@payment_claim)
      end
      redirect_to payment_claim_path(@payment_claim, sent: 1)
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @payment_claim.errors.add(:utr, "was already used for another unlock. Each payment's UTR works once. Check your latest receipt.")
    render :new, status: :unprocessable_entity
  end

  # 3g / 10b. The fan's receipt: waiting, approved, or bounced.
  def show
    @claim = PaymentClaim.find(params[:id])
    if @claim.creator_id == current_user.id && @claim.claimant_id != current_user.id
      return redirect_to(payment_claims_path(status: @claim.status))
    end
    raise ActiveRecord::RecordNotFound unless @claim.claimant_id == current_user.id

    @creator = @claim.creator
    @destination = destination_for(@claim)
    @ask_push = params[:sent].present? && WebPushNotifier.enabled? && current_user.push_subscriptions.none?
  end

  # 5b. The creator's queue.
  def index
    claims = current_user.received_payment_claims
    @status = params[:status].presence_in(%w[pending approved rejected all]) || "pending"
    scoped = @status == "all" ? claims : claims.where(status: @status)
    @claims = scoped.newest_first.includes(:claimant, :purchasable).limit(200)

    month = (Time.current.beginning_of_month..)
    @pending = claims.pending
    @pending_count = @pending.count
    @pending_amount = @pending.sum(:amount_cents)
    @oldest_pending = @pending.minimum(:created_at)
    @approved_month = claims.approved.where(reviewed_at: month)
    @rejected_month = claims.rejected.where(reviewed_at: month)
    reviewed = claims.approved.where(reviewed_at: 30.days.ago..).pluck(:created_at, :reviewed_at)
    @avg_minutes = reviewed.any? ? (reviewed.sum { |c, r| r - c } / reviewed.size / 60).round : nil

    respond_to do |format|
      format.html
      format.csv do
        send_data claims_csv(scoped.newest_first.includes(:claimant, :purchasable)),
                  filename: "wishful-payments-#{Date.current}.csv", type: "text/csv"
      end
    end
  end

  def approve
    claim = current_user.received_payment_claims.pending.find(params[:id])
    claim.approve!(current_user)
    redirect_back fallback_location: payment_claims_path, notice: "Approved. @#{claim.claimant.handle} has it now."
  rescue ActiveRecord::RecordInvalid, PaymentFulfillment::UnsupportedPurchasable => e
    redirect_back fallback_location: payment_claims_path, alert: "Could not grant access: #{e.message}"
  end

  def reject
    claim = current_user.received_payment_claims.pending.find(params[:id])
    claim.reject!(current_user, params[:reject_reason].presence || "Not in my account")
    redirect_back fallback_location: payment_claims_path, notice: "Rejected. @#{claim.claimant.handle} has been told to check the UTR."
  end

  # The fan paid less than the price. Rather than reject them outright, open
  # (or reuse) the DM thread with a message asking for the difference. The
  # claim stays pending until the creator sees the rest arrive.
  def nudge
    claim = current_user.received_payment_claims.pending.find(params[:id])
    short = claim.amount_cents - claim.claimed_amount_cents.to_i
    return redirect_to(payment_claims_path, alert: "That payment isn't short.") unless short.positive?

    conversation = Conversation.between(creator: current_user, fan: claim.claimant)
    body = "Hi! Your payment for #{claim.item_title} came in #{claim.money_label(short)} short " \
           "(#{claim.money_label(claim.claimed_amount_cents)} of #{claim.money_label}). " \
           "Send the remaining #{claim.money_label(short)} to #{current_user.upi_id.presence || "my UPI ID"} " \
           "and reply here with the UTR, and I'll unlock it."
    message = conversation.direct_messages.create!(sender: current_user, body: body)
    ConversationChannel.broadcast_to(conversation, { id: message.id, body: message.body, sender_id: current_user.id,
                                                     handle: current_user.handle, at: message.created_at.iso8601 })
    redirect_to conversation_path(conversation), notice: "Asked @#{claim.claimant.handle} for the rest."
  end

  private

  def require_payer
    return if signed_in?

    redirect_to fan_join_path(return_to: request.get? ? request.fullpath : nil)
  end

  def load_purchase
    @purchasable = find_purchasable
    @creator = creator_for(@purchasable)
    return redirect_to(root_path, alert: "This creator is not accepting payments right now.") unless @creator.accepts_upi_manual?
    return if deny_if_blocked_by(@creator)
    return redirect_to(profile_path(@creator.handle), alert: "You cannot pay yourself.") if @creator == current_user

    @amount_cents = amount_for(@purchasable)
    @list_id = params[:list].presence
  end

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
    when WishlistItem
      # A gift is any amount up to what is still needed, chosen in rupees on
      # the Spoil Me screen and carried through this form.
      chosen = params[:amount].present? ? (params[:amount].to_s.gsub(/[^0-9.]/, "").to_f * 100).round : nil
      remaining = record.remaining_cents
      chosen.to_i.positive? ? chosen.clamp(100, [ remaining, 100 ].max) : remaining
    else record.price_cents
    end
  end

  def currency_for(record)
    record.is_a?(MeetSlot) ? record.meet_offer.currency : record.currency
  end

  # Where the fan goes to enjoy what they paid for.
  def destination_for(claim)
    creator = claim.creator
    case claim.purchasable
    when PaidMediaCollection then public_collection_path(creator.handle, claim.purchasable)
    when PaidMediaPost then public_drop_path(creator.handle, claim.purchasable)
    when SubscriptionPlan then profile_path(creator.handle, tab: "collections")
    when ContactReveal, MeetSlot then profile_path(creator.handle, tab: "book")
    when WishlistItem then spoil_me_path(creator.handle)
    else profile_path(creator.handle)
    end
  end

  def claim_params
    params.require(:payment_claim).permit(:utr, :note, :proof)
  end

  def claims_csv(claims)
    CSV.generate do |csv|
      csv << %w[created_at fan item price paid currency utr status reviewed_at note]
      claims.each do |c|
        csv << [ c.created_at.iso8601, c.claimant.handle, c.item_title, c.amount_cents / 100.0,
                 (c.claimed_amount_cents || c.amount_cents) / 100.0, c.currency, c.utr, c.status,
                 c.reviewed_at&.iso8601, c.note ]
      end
    end
  end
end
