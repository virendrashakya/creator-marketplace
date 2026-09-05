class CreatorPostsController < ApplicationController
  before_action :require_user
  before_action :set_post, only: %i[edit update destroy]

  def new
    @creator_post = current_user.creator_posts.new
  end

  def create
    @creator_post = current_user.creator_posts.new(post_params)
    if @creator_post.save
      redirect_to dashboard_path, notice: "Post published."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @creator_post.update(post_params)
      redirect_to dashboard_path, notice: "Post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @creator_post.destroy
    redirect_to dashboard_path, notice: "Post removed."
  end

  private

  def set_post
    @creator_post = current_user.creator_posts.find(params[:id])
  end

  def post_params
    params.require(:creator_post).permit(:body, :media, :published)
  end
end
