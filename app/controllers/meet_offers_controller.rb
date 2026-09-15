class MeetOffersController < ApplicationController
  before_action :require_user
  before_action :set_meet_offer, only: %i[edit update destroy]

  def new
    @meet_offer = current_user.meet_offers.new(currency: "INR", duration_minutes: 30)
  end

  def create
    @meet_offer = current_user.meet_offers.new(meet_offer_params)
    if @meet_offer.save
      redirect_to edit_meet_offer_path(@meet_offer), notice: "Meet offer created. Add some time slots."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @meet_slot = @meet_offer.meet_slots.new
  end

  def update
    if @meet_offer.update(meet_offer_params)
      redirect_to dashboard_path, notice: "Meet offer updated."
    else
      @meet_slot = @meet_offer.meet_slots.new
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @meet_offer.destroy
    redirect_to dashboard_path, notice: "Meet offer removed."
  end

  private

  def set_meet_offer
    @meet_offer = current_user.meet_offers.find(params[:id])
  end

  def meet_offer_params
    params.require(:meet_offer).permit(:title, :description, :location, :price_cents, :currency, :duration_minutes, :published)
  end
end
