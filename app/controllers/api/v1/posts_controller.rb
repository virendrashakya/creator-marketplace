module Api
  module V1
    class PostsController < BaseController
      skip_before_action :authenticate_request!, only: %i[show]
      before_action :optional_authenticate_request!, only: %i[show]

      def show
        post = CreatorPost.where(published: true).find(params[:id])
        render json: { post: serialize_post(post) }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Post not found" }, status: :not_found
      end

      def like
        post = CreatorPost.where(published: true).find(params[:id])
        current_user.creator_post_likes.find_or_create_by!(creator_post: post)

        EventTracker.track(
          action: "post_like",
          actor: current_user.id,
          creator: post.user_id,
          target: post,
          request: request
        )

        render json: {
          success: true,
          is_liked: true,
          likes_count: post.reload.likes_count
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Post not found" }, status: :not_found
      end

      def unlike
        post = CreatorPost.where(published: true).find(params[:id])
        current_user.creator_post_likes.where(creator_post: post).destroy_all

        render json: {
          success: true,
          is_liked: false,
          likes_count: post.reload.likes_count
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Post not found" }, status: :not_found
      end

      def bookmark
        post = CreatorPost.where(published: true).find(params[:id])
        current_user.post_bookmarks.find_or_create_by!(creator_post: post)

        render json: {
          success: true,
          is_saved: true
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Post not found" }, status: :not_found
      end

      def unbookmark
        post = CreatorPost.where(published: true).find(params[:id])
        current_user.post_bookmarks.where(creator_post: post).destroy_all

        render json: {
          success: true,
          is_saved: false
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Post not found" }, status: :not_found
      end

      private

      def serialize_post(p)
        media_url = p.media.attached? ? Rails.application.routes.url_helpers.rails_blob_url(p.media, only_path: true) : nil
        creator = p.user

        {
          id: p.id,
          body: p.body,
          published_at: p.created_at,
          likes_count: p.likes_count,
          comments_count: p.comments_count,
          has_media: p.media.attached?,
          video: p.video?,
          media_url: media_url,
          paid_media_collection_id: p.paid_media_collection_id,
          item_type: p.item_type,
          category: p.category,
          badge: p.badge,
          tags: p.tags,
          drop_id_tag: p.drop_id_tag,
          is_liked: current_user ? current_user.likes_post?(p) : false,
          is_saved: current_user ? current_user.bookmarked_post?(p) : false,
          creator: {
            id: creator.id,
            handle: creator.handle,
            name: creator.name,
            avatar_url: creator.avatar_url,
            followers_count: creator.followers_count,
            is_following: current_user ? current_user.following?(creator) : false
          }
        }
      end
    end
  end
end
