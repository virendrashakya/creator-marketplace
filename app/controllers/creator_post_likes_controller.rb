class CreatorPostLikesController < ApplicationController
  before_action :require_user
  before_action :set_post
  before_action -> { deny_if_blocked_by(@creator_post.user) }

  def create
    current_user.creator_post_likes.find_or_create_by!(creator_post: @creator_post)

    # Async event tracking + notification to creator
    EventTracker.track(action: "post_like", actor: current_user, creator: @creator_post.user, target: @creator_post, request: request)
    NotifyJob.perform_later(
      user_id: @creator_post.user_id, kind: "new_like", actor_id: current_user.id,
      target_type: "CreatorPost", target_id: @creator_post.id,
      data: { "post_title" => @creator_post.title.to_s.truncate(60) }
    )

    redirect_back fallback_location: profile_path(@creator_post.user.handle)
  end

  def destroy
    current_user.creator_post_likes.where(creator_post: @creator_post).destroy_all

    EventTracker.track(action: "post_unlike", actor: current_user, creator: @creator_post.user, target: @creator_post, request: request)

    redirect_back fallback_location: profile_path(@creator_post.user.handle)
  end

  private

  def set_post
    @creator_post = CreatorPost.find(params[:creator_post_id])
  end
end

