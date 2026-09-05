class CollectionsController < ApplicationController
  before_action :require_user
  before_action :set_collection, only: %i[edit update destroy]

  def new
    @collection = current_user.link_collections.new
  end

  def create
    @collection = current_user.link_collections.new(collection_params)
    if @collection.save
      redirect_to dashboard_path, notice: "Collection created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @collection.update(collection_params)
      redirect_to dashboard_path, notice: "Collection updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy
    redirect_to dashboard_path, notice: "Collection removed. Its links are still available."
  end

  private

  def set_collection
    @collection = current_user.link_collections.find(params[:id])
  end

  def collection_params
    params.require(:link_collection).permit(:name, :position)
  end
end
