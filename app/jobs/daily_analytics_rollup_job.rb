class DailyAnalyticsRollupJob < ApplicationJob
  queue_as :analytics

  def perform(target_date = nil)
    date = target_date ? Date.parse(target_date.to_s) : Date.yesterday
    start_time = date.beginning_of_day
    end_time = date.end_of_day

    day_events = Event.where(created_at: start_time..end_time)

    rollup_creators(date, day_events)
    rollup_content(date, day_events)
    rollup_referrals(date, day_events)
  end

  private

  def rollup_creators(date, day_events)
    creator_ids = day_events.where.not(creator_id: nil).distinct.pluck(:creator_id)

    creator_ids.each do |creator_id|
      events = day_events.where(creator_id: creator_id)
      stat = CreatorDailyStat.find_or_initialize_by(creator_id: creator_id, date: date)

      stat.profile_views = events.where(action: "profile_view").count
      stat.unique_visitors = events.where(action: "profile_view").distinct.count(:actor_id)
      stat.pwa_visitors = events.where(action: "profile_view", device_type: "pwa").distinct.count(:actor_id)
      stat.web_visitors = [stat.unique_visitors - stat.pwa_visitors, 0].max

      stat.collection_views = events.where(action: "collection_view").count
      stat.post_views = events.where(action: "post_view").count
      stat.post_likes = events.where(action: "post_like").count
      stat.post_comments = events.where(action: "post_comment").count
      stat.post_shares = events.where(action: "share").where(target_type: "CreatorPost").count
      stat.media_views = events.where(action: "media_view").count
      stat.media_downloads = events.where(action: "media_download").count

      stat.collection_unlocks = events.where(action: "collection_unlock").count
      collection_revenue = events.where(action: "collection_unlock").sum("COALESCE((properties->>'amount_cents')::int, 0)")
      subscription_revenue = events.where(action: "subscribe").sum("COALESCE((properties->>'amount_cents')::int, 0)")
      gift_revenue = events.where(action: ["spoil_me_gift", "live_gift"]).sum("COALESCE((properties->>'amount_cents')::int, 0)")

      stat.collection_revenue_cents = collection_revenue
      stat.subscription_revenue_cents = subscription_revenue
      stat.gift_revenue_cents = gift_revenue
      stat.total_revenue_cents = collection_revenue + subscription_revenue + gift_revenue

      stat.new_followers = events.where(action: "follow").count
      stat.unfollows = events.where(action: "unfollow").count
      stat.new_subscribers = events.where(action: "subscribe").count
      stat.expired_subscribers = events.where(action: "subscribe_expire").count
      stat.messages_received = events.where(action: "message_send").count

      stat.link_list_opens = events.where(action: "link_list_open").count
      stat.link_list_taps = events.where(action: "link_list_tap").count

      stat.live_viewers = events.where(action: "live_join").distinct.count(:actor_id)
      stat.live_gifts_cents = events.where(action: "live_gift").sum("COALESCE((properties->>'amount_cents')::int, 0)")

      stat.claims_received = events.where(action: "pay_submit").count
      stat.claims_approved = events.where(action: "pay_approve").count
      stat.claims_rejected = events.where(action: "pay_reject").count

      stat.save!
    end
  end

  def rollup_content(date, day_events)
    content_events = day_events.where.not(target_type: nil, target_id: nil)

    content_groups = content_events.distinct.pluck(:content_type, :content_id) rescue []
    content_targets = content_events.distinct.pluck(:target_type, :target_id)

    content_targets.each do |target_type, target_id|
      events = content_events.where(target_type: target_type, target_id: target_id)
      creator_id = events.first&.creator_id
      next unless creator_id

      stat = ContentDailyStat.find_or_initialize_by(
        content_type: target_type,
        content_id: target_id,
        date: date
      )
      stat.creator_id = creator_id

      stat.views = events.where(action: ["collection_view", "post_view", "link_list_open", "drop_view"]).count
      stat.unique_views = events.where(action: ["collection_view", "post_view", "link_list_open", "drop_view"]).distinct.count(:actor_id)
      stat.likes = events.where(action: "post_like").count
      stat.comments = events.where(action: "post_comment").count
      stat.shares = events.where(action: "share").count
      stat.unlocks = events.where(action: "collection_unlock").count
      stat.revenue_cents = events.where(action: "collection_unlock").sum("COALESCE((properties->>'amount_cents')::int, 0)")
      stat.taps = events.where(action: "link_list_tap").count
      stat.pay_sheet_opens = events.where(action: "pay_start").count
      stat.utr_submissions = events.where(action: "pay_submit").count
      stat.conversions = events.where(action: "pay_approve").count

      stat.save!
    end
  end

  def rollup_referrals(date, day_events)
    referral_events = day_events.where.not(creator_id: nil, source: nil)

    pairs = referral_events.distinct.pluck(:creator_id, :source)
    pairs.each do |creator_id, source|
      events = referral_events.where(creator_id: creator_id, source: source)
      stat = ReferralDailyStat.find_or_initialize_by(
        creator_id: creator_id,
        date: date,
        source: source
      )
      stat.visits = events.where(action: "profile_view").count
      stat.unique_visitors = events.where(action: "profile_view").distinct.count(:actor_id)
      stat.follows = events.where(action: "follow").count
      stat.unlocks = events.where(action: "collection_unlock").count
      stat.revenue_cents = events.where(action: "collection_unlock").sum("COALESCE((properties->>'amount_cents')::int, 0)")

      stat.save!
    end
  end
end
