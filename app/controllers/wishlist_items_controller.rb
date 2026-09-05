class WishlistItemsController < ApplicationController
  before_action :require_user
  before_action :set_wishlist, except: :contribute
  before_action :set_item, only: %i[edit update destroy]
  def new; @wishlist_item = @wishlist.wishlist_items.new(currency: "INR"); end
  def create; @wishlist_item = @wishlist.wishlist_items.new(item_params); @wishlist_item.save ? (redirect_to(dashboard_path, notice: "Gift item added.")) : (render :new, status: :unprocessable_entity); end
  def edit; end
  def update; @wishlist_item.update(item_params) ? (redirect_to(dashboard_path, notice: "Gift item updated.")) : (render :edit, status: :unprocessable_entity); end
  def destroy; @wishlist_item.destroy; redirect_to dashboard_path, notice: "Gift item removed."; end
  def contribute
    item = WishlistItem.find(params[:id])
    return redirect_to(profile_path(item.wishlist.user.handle), alert: "You cannot gift your own wishlist item.") if item.wishlist.user == current_user
    amount = item.remaining_cents
    contribution = current_user.gift_contributions.create!(wishlist_item: item, amount_cents: amount, status: "paid", payment_reference: "test_gift_#{SecureRandom.hex(8)}")
    item.update!(status: "funded") if item.remaining_cents.zero?
    redirect_to profile_path(item.wishlist.user.handle), notice: "Test contribution of #{contribution.amount_cents} paise recorded — no payment was collected."
  end
  private
  def set_wishlist; @wishlist = current_user.wishlists.find(params[:wishlist_id]); end
  def set_item; @wishlist_item = @wishlist.wishlist_items.find(params[:id]); end
  def item_params; params.require(:wishlist_item).permit(:title, :product_url, :image_url, :target_cents, :currency, :note, :status); end
end
