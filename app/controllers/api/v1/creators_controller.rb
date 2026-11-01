module Api
  module V1
    class CreatorsController < BaseController
      skip_before_action :authenticate_request!, only: %i[show]
      before_action :optional_authenticate_request!, only: %i[show]

      def show
        creator = User.find_by("LOWER(handle) = ?", params[:handle].to_s.downcase)
        return render json: { error: "Creator not found" }, status: :not_found unless creator

        # Record profile view event
        EventTracker.track(
          action: "profile_view",
          actor: current_user&.id || 0,
          creator: creator.id,
          request: request
        )

        collections = creator.paid_media_collections.live.order(created_at: :desc)
        posts = creator.creator_posts.where(published: true).order(created_at: :desc)
        lives = creator.live_sessions.visible.upcoming

        is_following = current_user ? current_user.following?(creator) : false

        render json: {
          creator: {
            id: creator.id,
            name: creator.name,
            handle: creator.handle,
            bio: creator.bio,
            category: creator.creator_category,
            location: creator.location,
            followers_count: creator.followers_count,
            posts_count: posts.count,
            collections_count: collections.count,
            avatar_url: creator.avatar_url,
            is_following: is_following,
            upi_id: creator.upi_id
          },
          collections: collections.map { |c| serialize_collection(c) },
          posts: posts.map { |p| serialize_post(p) },
          lives: lives.map { |l| serialize_live(l) }
        }
      end

      def follow
        creator = User.find_by("LOWER(handle) = ?", params[:handle].to_s.downcase)
        return render json: { error: "Creator not found" }, status: :not_found unless creator
        return render json: { error: "Cannot follow yourself" }, status: :unprocessable_entity if current_user.id == creator.id

        current_user.following_relationships.find_or_create_by!(creator: creator)

        # Immediately seed recent posts & drops into fan's feed
        creator.creator_posts.where(published: true).order(created_at: :desc).limit(10).each do |p|
          item = current_user.feed_items.find_or_initialize_by(
            target_type: "CreatorPost",
            target_id: p.id
          )
          item.creator_id = creator.id
          item.item_type = "post"
          item.published_at = p.created_at
          item.score = 0.0
          item.save if item.new_record?
        end

        creator.paid_media_collections.live.order(created_at: :desc).limit(5).each do |c|
          item = current_user.feed_items.find_or_initialize_by(
            target_type: "PaidMediaCollection",
            target_id: c.id
          )
          item.creator_id = creator.id
          item.item_type = "collection"
          item.published_at = c.release_at || c.created_at
          item.score = 2.0
          item.save if item.new_record?
        end

        render json: { success: true, followers_count: creator.reload.followers_count, is_following: true }
      end

      def unfollow
        creator = User.find_by("LOWER(handle) = ?", params[:handle].to_s.downcase)
        return render json: { error: "Creator not found" }, status: :not_found unless creator

        current_user.following_relationships.where(creator: creator).destroy_all
        current_user.feed_items.where(creator_id: creator.id).destroy_all
        render json: { success: true, followers_count: creator.reload.followers_count, is_following: false }
      end

      private

      def serialize_collection(c)
        cover = c.cover_post
        unlocked = current_user ? c.unlocked_for?(current_user) : false
        posts = unlocked ? c.paid_media_posts.order(position: :asc).map do |p|
          {
            id: p.id,
            caption: p.caption,
            media_type: p.media_type,
            media_url: "/paid_media_posts/#{p.id}/media",
            preview_url: "/paid_media_posts/#{p.id}/preview"
          }
        end : []

        {
          id: c.id,
          title: c.title,
          description: c.description,
          price_cents: c.price_cents,
          currency: c.currency,
          items_count: c.paid_media_posts.count,
          unlocks_count: c.unlocks_count,
          cover_image_url: cover.present? ? "/paid_media_posts/#{cover.id}/preview" : nil,
          unlocked: unlocked,
          posts: posts
        }
      end

      def serialize_post(p)
        {
          id: p.id,
          body: p.body,
          created_at: p.created_at,
          likes_count: p.likes_count,
          comments_count: p.comments_count,
          has_media: p.media.attached?,
          video: p.video?,
          media_url: p.media.attached? ? Rails.application.routes.url_helpers.rails_blob_url(p.media, only_path: true) : nil
        }
      end

      def serialize_live(l)
        {
          id: l.id,
          title: l.title,
          scheduled_for: l.scheduled_for,
          status: l.status,
          access: l.access
        }
      end
    end
  end
end
