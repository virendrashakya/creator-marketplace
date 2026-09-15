class ContactRevealsController < ApplicationController
  before_action :require_user
  before_action :set_contact_reveal, only: %i[edit update destroy]

  def new
    @contact_reveal = current_user.contact_reveals.new(currency: "INR")
  end

  def create
    @contact_reveal = current_user.contact_reveals.new(contact_reveal_params)
    if @contact_reveal.save
      redirect_to dashboard_path, notice: "Contact reveal published."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @contact_reveal.update(contact_reveal_params)
      redirect_to dashboard_path, notice: "Contact reveal updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact_reveal.destroy
    redirect_to dashboard_path, notice: "Contact reveal removed."
  end

  # Test-mode checkout. Replace with a real payment intent + webhook before
  # production; access must be granted by the webhook, not here.
  def purchase
    reveal = ContactReveal.published.find(params[:id])
    return redirect_to(profile_path(reveal.user.handle), alert: "You cannot purchase your own contact.") if reveal.user == current_user
    return if deny_if_blocked_by(reveal.user)

    purchase = current_user.access_purchases.find_or_initialize_by(purchasable: reveal)
    purchase.assign_attributes(amount_cents: reveal.price_cents, currency: reveal.currency, status: "paid", payment_reference: "test_contact_#{SecureRandom.hex(8)}")
    if purchase.save
      redirect_to profile_path(reveal.user.handle), notice: "Revealed in test mode — no payment was collected."
    else
      redirect_to profile_path(reveal.user.handle), alert: purchase.errors.full_messages.to_sentence
    end
  end

  private

  def set_contact_reveal
    @contact_reveal = current_user.contact_reveals.find(params[:id])
  end

  def contact_reveal_params
    params.require(:contact_reveal).permit(:label, :secret_value, :price_cents, :currency, :published)
  end
end
