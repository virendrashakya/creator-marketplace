class ProductLinksController < ApplicationController
  before_action :require_user, except: :visit
  before_action :set_product_link, only: %i[edit update destroy]

  def new
    @product_link = current_user.product_links.new
  end

  def create
    @product_link = current_user.product_links.new(product_link_params)
    if @product_link.save
      redirect_to dashboard_path, notice: "Recommendation published."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @product_link.update(product_link_params)
      redirect_to dashboard_path, notice: "Recommendation updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product_link.destroy
    redirect_to dashboard_path, notice: "Recommendation removed."
  end

  def visit
    link = ProductLink.find(params[:id])
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
