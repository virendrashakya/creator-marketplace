class CreatorPostCommentsController < ApplicationController
  before_action :require_user

  def create
    post = CreatorPost.find(params[:creator_post_id])
    return if deny_if_blocked_by(post.user)

    comment = post.creator_post_comments.new(body: params.require(:creator_post_comment).fetch(:body), user: current_user)
    if comment.save
      redirect_back fallback_location: profile_path(post.user.handle)
    else
      redirect_back fallback_location: profile_path(post.user.handle), alert: comment.errors.full_messages.to_sentence
    end
  end
end
