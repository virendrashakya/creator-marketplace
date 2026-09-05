class WishlistsController < ApplicationController
  before_action :require_user
  before_action :set_wishlist, only: %i[edit update destroy]
  def new; @wishlist = current_user.wishlists.new; end
  def create; @wishlist = current_user.wishlists.new(wishlist_params); @wishlist.save ? (redirect_to(dashboard_path, notice: "Wishlist created.")) : (render :new, status: :unprocessable_entity); end
  def edit; end
  def update; @wishlist.update(wishlist_params) ? (redirect_to(dashboard_path, notice: "Wishlist updated.")) : (render :edit, status: :unprocessable_entity); end
  def destroy; @wishlist.destroy; redirect_to dashboard_path, notice: "Wishlist removed."; end
  private
  def set_wishlist; @wishlist = current_user.wishlists.find(params[:id]); end
  def wishlist_params; params.require(:wishlist).permit(:title, :description, :published); end
end
