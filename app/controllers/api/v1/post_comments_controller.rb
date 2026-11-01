module Api
  module V1
    class PostCommentsController < BaseController
      skip_before_action :authenticate_request!, only: %i[index]
      before_action :optional_authenticate_request!, only: %i[index]

      def index
        post = CreatorPost.where(published: true).find(params[:post_id])
        comments = post.creator_post_comments.includes(:user).order(created_at: :desc).limit(50)

        render json: {
          comments: comments.map { |c| serialize_comment(c, post) },
          comments_count: post.comments_count
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Post not found" }, status: :not_found
      end

      def create
        post = CreatorPost.where(published: true).find(params[:post_id])
        body = params[:body].to_s.strip

        if body.blank?
          return render json: { error: "Comment cannot be blank" }, status: :unprocessable_entity
        end

        comment = post.creator_post_comments.new(user: current_user, body: body)

        if comment.save
          EventTracker.track(
            action: "post_comment",
            actor: current_user.id,
            creator: post.user_id,
            target: post,
            properties: { comment_id: comment.id },
            request: request
          )

          render json: {
            success: true,
            comment: serialize_comment(comment, post),
            comments_count: post.reload.comments_count
          }, status: :created
        else
          render json: { error: comment.errors.full_messages.to_sentence }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Post not found" }, status: :not_found
      end

      private

      def serialize_comment(c, post)
        author = c.user
        is_creator = author.id == post.user_id
        is_vip = author.subscribed_to_creator?(post.user)

        {
          id: c.id,
          text: c.body,
          created_at: c.created_at,
          author: author.name,
          handle: author.handle,
          avatar_url: author.avatar_url,
          vip: is_vip,
          is_creator: is_creator,
          time_ago: time_ago(c.created_at)
        }
      end

      def time_ago(time)
        diff = (Time.current - time).to_i
        if diff < 60
          "Just now"
        elsif diff < 3600
          "#{diff / 60}m ago"
        elsif diff < 86400
          "#{diff / 3600}h ago"
        else
          "#{diff / 86400}d ago"
        end
      end
    end
  end
end
