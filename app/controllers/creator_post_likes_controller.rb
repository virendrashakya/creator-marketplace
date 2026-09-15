class CreatorPostLikesController < ApplicationController
  before_action :require_user
  before_action :set_post
  before_action -> { deny_if_blocked_by(@creator_post.user) }

  def create
    current_user.creator_post_likes.find_or_create_by!(creator_post: @creator_post)
    redirect_back fallback_location: profile_path(@creator_post.user.handle)
  end

  def destroy
    current_user.creator_post_likes.where(creator_post: @creator_post).destroy_all
    redirect_back fallback_location: profile_path(@creator_post.user.handle)
  end

  private

  def set_post
    @creator_post = CreatorPost.find(params[:creator_post_id])
  end
end
