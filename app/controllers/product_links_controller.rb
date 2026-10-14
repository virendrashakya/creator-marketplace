class ProductLinksController < ApplicationController
  before_action :require_user, except: :visit
  before_action :set_product_link, only: %i[edit update destroy]

  # Studio · Shop. The looks on the storefront's Shop tab, with their taps.
  def index
    @categories = current_user.link_collections.to_a
    @links = current_user.product_links.includes(:link_collection)
    @links = @links.where(link_collection_id: params[:cat]) if params[:cat].present?
    @total_clicks = current_user.product_links.sum(:clicks_count)
  end

  def new
    @product_link = current_user.product_links.new
  end

  def create
    @product_link = current_user.product_links.new(product_link_params)
    if @product_link.save
      redirect_to product_links_path, notice: "Recommendation published."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @product_link.update(product_link_params)
      redirect_to product_links_path, notice: "Recommendation updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product_link.destroy
    redirect_to product_links_path, notice: "Recommendation removed."
  end

  def visit
    link = ProductLink.find(params[:id])
    # Re-checked at redirect time: validation only covers rows written after it
    # was added, and a creator may have edited the row in between.
    if ProductLink.http_url_error(link.url)
      return redirect_to profile_path(link.user.handle), alert: "That link is no longer available."
    end

    link.link_clicks.create(referrer: request.referer, ip_hash: Digest::SHA256.hexdigest(request.remote_ip.to_s))
    redirect_to link.url, allow_other_host: true
  end

  private

  def set_product_link
    @product_link = current_user.product_links.find(params[:id])
  end

  def product_link_params
    params.require(:product_link).permit(:title, :url, :image_url, :merchant, :price, :description, :featured, :position, :link_collection_id)
  end
end
