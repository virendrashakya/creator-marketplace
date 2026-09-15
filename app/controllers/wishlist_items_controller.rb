class WishlistItemsController < ApplicationController
  before_action :require_user
  before_action :set_wishlist, except: :contribute
  before_action :set_item, only: %i[edit update destroy]

  def new
    @wishlist_item = @wishlist.wishlist_items.new(currency: "INR")
  end

  def create
    @wishlist_item = @wishlist.wishlist_items.new(item_params)
    if @wishlist_item.save
      redirect_to dashboard_path, notice: "Gift item added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @wishlist_item.update(item_params)
      redirect_to dashboard_path, notice: "Gift item updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @wishlist_item.destroy
    redirect_to dashboard_path, notice: "Gift item removed."
  end

  # Test-mode checkout. Replace with a real payment intent + webhook before
  # production; the contribution must be confirmed by the webhook, not here.
  def contribute
    item = WishlistItem.find(params[:id])
    creator = item.wishlist.user
    return redirect_to(profile_path(creator.handle), alert: "You cannot gift your own wishlist item.") if creator == current_user
    return if deny_if_blocked_by(creator)

    contribution = nil
    error = nil

    # Locked so concurrent gifts cannot both read the same remaining balance
    # and overfund the item.
    item.with_lock do
      remaining = item.remaining_cents
      if remaining.zero? || item.status != "available"
        error = "That gift has already been fully funded."
        next
      end

      amount = requested_amount_cents(remaining)
      if amount.nil?
        error = "Enter a gift amount between #{item.money_label(1)} and #{item.money_label(remaining)}."
        next
      end

      contribution = current_user.gift_contributions.create!(
        wishlist_item: item,
        amount_cents: amount,
        message: params[:message].presence,
        status: "paid",
        payment_reference: "test_gift_#{SecureRandom.hex(8)}"
      )
      item.refresh_funding_status!
    end

    return redirect_to(profile_path(creator.handle), alert: error) if error

    redirect_to profile_path(creator.handle),
                notice: "Test contribution of #{item.money_label(contribution.amount_cents)} recorded — no payment was collected."
  end

  private

  # nil when the giver asked for something outside 1..remaining. Defaults to
  # the full remaining balance when no amount is supplied.
  def requested_amount_cents(remaining)
    raw = params[:amount_cents]
    return remaining if raw.blank?
    return nil unless /\A\d+\z/.match?(raw.to_s.strip)

    amount = raw.to_i
    return nil if amount < 1 || amount > remaining

    amount
  end

  def set_wishlist
    @wishlist = current_user.wishlists.find(params[:wishlist_id])
  end

  def set_item
    @wishlist_item = @wishlist.wishlist_items.find(params[:id])
  end

  def item_params
    params.require(:wishlist_item).permit(:title, :product_url, :image_url, :target_cents, :currency, :note, :status)
  end
end
