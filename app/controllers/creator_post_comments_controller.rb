class CreatorPostCommentsController < ApplicationController
  before_action :require_user

  def create
    post = CreatorPost.find(params[:creator_post_id])
    return if deny_if_blocked_by(post.user)

    comment = post.creator_post_comments.new(body: params.require(:creator_post_comment).fetch(:body), user: current_user)
    if comment.save
      # Async event tracking + notification to creator
      EventTracker.track(action: "post_comment", actor: current_user, creator: post.user, target: post, request: request)
      NotifyJob.perform_later(
        user_id: post.user_id, kind: "new_comment", actor_id: current_user.id,
        target_type: "CreatorPost", target_id: post.id,
        data: { "comment_preview" => comment.body.truncate(80) }
      )

      redirect_back fallback_location: profile_path(post.user.handle)
    else
      redirect_back fallback_location: profile_path(post.user.handle), alert: comment.errors.full_messages.to_sentence
    end
  end
end

