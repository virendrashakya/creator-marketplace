class MeetSlotsController < ApplicationController
  before_action :require_user

  def create
    @meet_offer = current_user.meet_offers.find(params[:meet_offer_id])
    @meet_slot = @meet_offer.meet_slots.new(meet_slot_params)
    if @meet_slot.save
      redirect_to edit_meet_offer_path(@meet_offer), notice: "Slot added."
    else
      render "meet_offers/edit", status: :unprocessable_entity
    end
  end

  def destroy
    @meet_offer = current_user.meet_offers.find(params[:meet_offer_id])
    slot = @meet_offer.meet_slots.find(params[:id])
    return redirect_to(edit_meet_offer_path(@meet_offer), alert: "That slot is already booked.") if slot.booked?

    slot.destroy
    redirect_to edit_meet_offer_path(@meet_offer), notice: "Slot removed."
  end

  # Test-mode checkout. Replace with a real payment intent + webhook before
  # production; the booking must be confirmed by the webhook, not here.
  def book
    slot = MeetSlot.find(params[:id])
    offer = slot.meet_offer
    return redirect_to(profile_path(offer.user.handle), alert: "You cannot book your own meet.") if offer.user == current_user
    return if deny_if_blocked_by(offer.user)
    return redirect_to(profile_path(offer.user.handle), alert: "That slot has already started.") if slot.starts_at <= Time.current

    MeetBooking.create!(
      meet_slot: slot,
      attendee: current_user,
      amount_cents: offer.price_cents,
      currency: offer.currency,
      status: "paid",
      payment_reference: "test_meet_#{SecureRandom.hex(8)}"
    )
    redirect_to profile_path(offer.user.handle), notice: "Booked in test mode — no payment was collected."
  rescue ActiveRecord::RecordNotUnique
    # The unique index on meet_slot_id is what actually prevents double booking;
    # two concurrent requests both pass any read-time check.
    redirect_to profile_path(offer.user.handle), alert: "Someone just booked that slot."
  end

  private

  def meet_slot_params
    params.require(:meet_slot).permit(:starts_at, :ends_at)
  end
end
