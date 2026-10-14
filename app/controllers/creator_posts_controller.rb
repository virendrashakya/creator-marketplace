# Free, public posts. Studio's Posts screen (5e) is the grid plus a composer;
# the public post page is what a fan opens from the Posts tab.
class CreatorPostsController < ApplicationController
  before_action :require_user, except: :show
  before_action :set_post, only: %i[edit update destroy]

  def index
    load_studio_posts
    @creator_post = current_user.creator_posts.new(published: true)
  end

  def new
    redirect_to creator_posts_path
  end

  def create
    @creator_post = current_user.creator_posts.new(post_params)
    if @creator_post.save
      redirect_to creator_posts_path, notice: @creator_post.published? ? "Posted." : "Saved as a draft."
    else
      load_studio_posts
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find_by!(handle: params[:handle].to_s.downcase)
    return head :not_found if @user.blocks?(current_user)

    scope = current_user == @user ? @user.creator_posts : @user.creator_posts.where(published: true)
    @post = scope.includes(:creator_post_likes, creator_post_comments: :user).find(params[:id])
  end

  def edit; end

  def update
    if @creator_post.update(post_params)
      redirect_to creator_posts_path, notice: "Post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @creator_post.destroy
    redirect_to creator_posts_path, notice: "Post removed."
  end

  private

  def load_studio_posts
    @posts = current_user.creator_posts.with_attached_media.includes(:creator_post_likes).order(created_at: :desc)
    @collections = current_user.paid_media_collections.order(created_at: :desc)
  end

  def set_post
    @creator_post = current_user.creator_posts.find(params[:id])
  end

  def post_params
    params.require(:creator_post).permit(:body, :media, :published, :paid_media_collection_id)
  end
end
