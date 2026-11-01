module Api
  module V1
    class FeedController < BaseController
      skip_before_action :authenticate_request!, only: %i[index]
      before_action :optional_authenticate_request!, only: %i[index]

      def index
        items = []

        if current_user
          followed_creator_ids = current_user.following_relationships.pluck(:creator_id)

          if followed_creator_ids.any?
            # Ensure followed creators' recent posts are in the feed
            CreatorPost.where(published: true, user_id: followed_creator_ids).order(created_at: :desc).limit(30).each do |p|
              item = FeedItem.find_or_initialize_by(
                fan_id: current_user.id,
                target_type: "CreatorPost",
                target_id: p.id
              )
              item.creator_id = p.user_id
              item.item_type = p.item_type
              item.published_at = p.created_at
              item.score = 0.0
              item.save if item.new_record?
            end

            # Ensure followed creators' recent collections are in the feed
            PaidMediaCollection.live.where(user_id: followed_creator_ids).order(created_at: :desc).limit(20).each do |c|
              item = FeedItem.find_or_initialize_by(
                fan_id: current_user.id,
                target_type: "PaidMediaCollection",
                target_id: c.id
              )
              item.creator_id = c.user_id
              item.item_type = "collection"
              item.published_at = c.release_at || c.created_at
              item.score = 2.0
              item.save if item.new_record?
            end

            # Ensure followed creators' live sessions are in the feed
            LiveSession.visible.where(user_id: followed_creator_ids).limit(10).each do |l|
              item = FeedItem.find_or_initialize_by(
                fan_id: current_user.id,
                target_type: "LiveSession",
                target_id: l.id
              )
              item.creator_id = l.user_id
              item.item_type = l.status == "finished" ? "live_replay" : "live"
              item.published_at = l.scheduled_for || l.created_at
              item.score = 5.0
              item.save if item.new_record?
            end

            feed_records = current_user.feed_items.where(creator_id: followed_creator_ids).recent.includes(:creator).limit(50)
            items = feed_records.map { |r| serialize_feed_item(r) }.compact
          end
        end

        # If user follows no creators or is a guest, supply curated discovery feed
        if items.empty?
          items = curated_discovery_feed
        end

        render json: { feed_items: items }
      end

      def seen
        item = current_user&.feed_items&.find_by(id: params[:id])
        item&.mark_seen!
        head :ok
      end

      private

      def curated_discovery_feed
        top_creators = User.where(account_type: "creator").order(followers_count: :desc).limit(10)
        top_creator_ids = top_creators.pluck(:id)

        guest_collections = PaidMediaCollection.live.where(user_id: top_creator_ids).order(created_at: :desc).limit(8)
        guest_posts = CreatorPost.where(published: true, user_id: top_creator_ids).order(created_at: :desc).limit(16)
        guest_lives = LiveSession.visible.where(user_id: top_creator_ids).order(created_at: :desc).limit(4)

        result = []

        guest_collections.each do |c|
          cover = c.cover_post
          unlocked = current_user ? c.unlocked_for?(current_user) : false
          result << {
            id: "c_#{c.id}",
            item_type: "collection",
            published_at: c.created_at.iso8601,
            creator: serialize_creator(c.user),
            badge: "VIP VAULT DROP",
            subline: "12-Piece Uncut Digital Set • Raw Studio Edit",
            dropIdTag: "##{c.user.handle.upcase}-VAULT-#{c.id}",
            tags: ["#AfterDark", "#VIPVault", "#ExclusiveSet"],
            category: "teasers",
            target: {
              id: c.id,
              title: c.title,
              description: c.description,
              price_cents: c.price_cents,
              currency: c.currency,
              items_count: c.paid_media_posts.count,
              unlocks_count: c.unlocks_count,
              handle: c.user.handle,
              cover_image_url: cover ? "/paid_media_posts/#{cover.id}/preview" : nil,
              unlocked: unlocked,
              likes_count: 4900,
              comments_count: 340,
              bookmarks_count: 890,
              is_liked: false,
              is_saved: false
            }
          }
        end

        guest_posts.each do |p|
          result << serialize_post_feed_item(p)
        end

        guest_lives.each do |l|
          is_replay = l.status == "finished"
          result << {
            id: "l_#{l.id}",
            item_type: is_replay ? "live_replay" : "live",
            published_at: (l.scheduled_for || l.created_at).iso8601,
            creator: serialize_creator(l.user),
            badge: is_replay ? "UNCUT STREAM ARCHIVE" : "UPCOMING VIP LIVE",
            subline: is_replay ? "Streamed recently • Candlelit Q&A" : "Live stream starting soon",
            dropIdTag: "##{l.user.handle.upcase}-LIVE-#{l.id}",
            tags: ["#AfterDarkLive", "#CandlelitRoom", "#PPVReplay"],
            category: "close_friends",
            stream: {
              statusText: is_replay ? "Stream Ended • 1,420 tuned in" : "Scheduled Live Session",
              duration: "48:22 Full Duration",
              archiveTitle: "48M UNCUT STREAM LOCKED • ₹299",
              setupNote: "1080p 60FPS Raw Archive Candlelit Setup"
            },
            target: {
              id: l.id,
              title: l.title,
              body: "Missed the live broadcast? The uncut replay is now archived for lounge members. Answering all your direct questions unfiltered! 🔥",
              scheduled_for: l.scheduled_for,
              status: l.status,
              access: l.access,
              price_cents: 29900,
              currency: "INR",
              likes_count: 3500,
              comments_count: 490,
              bookmarks_count: 910,
              is_liked: false,
              is_saved: false
            }
          }
        end

        result.sort_by { |i| i[:published_at] }.reverse
      end

      def serialize_feed_item(item)
        target = item.target
        creator = item.creator
        return nil unless creator && target

        case target
        when CreatorPost
          serialize_post_feed_item(target, feed_item_id: item.id.to_s)
        when PaidMediaCollection
          cover = target.cover_post
          unlocked = current_user ? target.unlocked_for?(current_user) : false
          {
            id: "c_#{target.id}",
            item_type: "collection",
            published_at: item.published_at.iso8601,
            creator: serialize_creator(creator),
            badge: "VIP VAULT DROP",
            subline: "12-Piece Uncut Digital Set • Raw Studio Edit",
            dropIdTag: "##{creator.handle.upcase}-VAULT-#{target.id}",
            tags: ["#AfterDark", "#VIPVault", "#ExclusiveSet"],
            category: "teasers",
            target: {
              id: target.id,
              title: target.title,
              description: target.description,
              price_cents: target.price_cents,
              currency: target.currency,
              items_count: target.paid_media_posts.count,
              unlocks_count: target.unlocks_count,
              handle: creator.handle,
              cover_image_url: cover ? "/paid_media_posts/#{cover.id}/preview" : nil,
              unlocked: unlocked,
              likes_count: 4900,
              comments_count: 340,
              bookmarks_count: 890,
              is_liked: false,
              is_saved: false
            }
          }
        when LiveSession
          is_replay = target.status == "finished"
          {
            id: "l_#{target.id}",
            item_type: is_replay ? "live_replay" : "live",
            published_at: item.published_at.iso8601,
            creator: serialize_creator(creator),
            badge: is_replay ? "UNCUT STREAM ARCHIVE" : "UPCOMING VIP LIVE",
            subline: is_replay ? "Streamed recently • Candlelit Q&A" : "Live stream starting soon",
            dropIdTag: "##{creator.handle.upcase}-LIVE-#{target.id}",
            tags: ["#AfterDarkLive", "#CandlelitRoom", "#PPVReplay"],
            category: "close_friends",
            stream: {
              statusText: is_replay ? "Stream Ended • 1,420 tuned in" : "Scheduled Live Session",
              duration: "48:22 Full Duration",
              archiveTitle: "48M UNCUT STREAM LOCKED • ₹299",
              setupNote: "1080p 60FPS Raw Archive Candlelit Setup"
            },
            target: {
              id: target.id,
              title: target.title,
              body: "Missed the live broadcast? The uncut replay is now archived for lounge members. Answering all your direct questions unfiltered! 🔥",
              scheduled_for: target.scheduled_for,
              status: target.status,
              access: target.access,
              price_cents: 29900,
              currency: "INR",
              likes_count: 3500,
              comments_count: 490,
              bookmarks_count: 910,
              is_liked: false,
              is_saved: false
            }
          }
        else
          nil
        end
      end

      def serialize_post_feed_item(p, feed_item_id: nil)
        media_url = p.media.attached? ? Rails.application.routes.url_helpers.rails_blob_url(p.media, only_path: true) : nil
        creator = p.user
        itype = p.item_type

        poll_data = nil
        if itype == "poll"
          poll_data = {
            question: p.body.sub(/GRWM poll:\s*/i, "").sub(/Poll:\s*/i, ""),
            closesIn: "Closes in 6 hours",
            totalVotes: 502,
            options: [
              { id: 1, text: "Sheer Rose Bodysuit · 341 votes", votes: 341, percent: 68 },
              { id: 2, text: "Obsidian Midnight Silk · 161 votes", votes: 161, percent: 32 }
            ]
          }
        end

        audio_data = nil
        if itype == "audio"
          audio_data = {
            title: "Bedside Confessions (Uncut)",
            subtitle: "Uncompressed Binaural Studio Recording",
            duration: "02:14",
            listens: "1,840 Listens"
          }
        end

        {
          id: feed_item_id || "p_#{p.id}",
          item_type: itype,
          published_at: p.created_at.iso8601,
          creator: serialize_creator(creator),
          badge: p.badge,
          subline: "@#{creator.handle} • #{time_ago(p.created_at)}",
          dropIdTag: p.drop_id_tag,
          tags: p.tags,
          category: p.category,
          poll: poll_data,
          audio: audio_data,
          target: {
            id: p.id,
            body: p.body,
            likes_count: p.likes_count,
            comments_count: p.comments_count,
            has_media: p.media.attached?,
            video: p.video?,
            media_url: media_url,
            paid_media_collection_id: p.paid_media_collection_id,
            is_liked: current_user ? current_user.likes_post?(p) : false,
            is_saved: current_user ? current_user.bookmarked_post?(p) : false
          }
        }
      end

      def serialize_creator(creator)
        return nil unless creator
        {
          id: creator.id,
          handle: creator.handle,
          name: creator.name,
          avatar_url: creator.avatar_url,
          bio: creator.bio,
          followers_count: creator.followers_count,
          is_following: current_user ? current_user.following?(creator) : false
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
