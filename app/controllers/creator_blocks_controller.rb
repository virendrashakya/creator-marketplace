class CreatorBlocksController < ApplicationController
  before_action :require_user

  def index
    @blocks = current_user.creator_blocks.order(created_at: :desc)
  end

  def new
    @creator_block = current_user.creator_blocks.new(identifier_type: "username")
  end

  def create
    @creator_block = current_user.creator_blocks.new(block_params)
    if @creator_block.save
      redirect_to creator_blocks_path, notice: "Account identifier blocked."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.creator_blocks.find(params[:id]).destroy
    redirect_to creator_blocks_path, notice: "Block removed."
  end

  private

  def block_params
    params.require(:creator_block).permit(:identifier_type, :identifier_value, :reason)
  end
end
