class PaidMediaCollectionsController < ApplicationController
  before_action :require_user
  before_action :set_collection, only: %i[edit update destroy]

  def new
    @paid_media_collection = current_user.paid_media_collections.new(currency: "INR")
  end

  def create
    @paid_media_collection = current_user.paid_media_collections.new(collection_params)
    if @paid_media_collection.save
      redirect_to dashboard_path, notice: "Media collection created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @paid_media_collection.update(collection_params)
      redirect_to dashboard_path, notice: "Media collection updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @paid_media_collection.destroy
    redirect_to dashboard_path, notice: "Media collection removed."
  end

  private

  def set_collection
    @paid_media_collection = current_user.paid_media_collections.find(params[:id])
  end

  def collection_params
    params.require(:paid_media_collection).permit(:title, :description, :price_cents, :currency, :published, :subscription_plan_id)
  end
end
