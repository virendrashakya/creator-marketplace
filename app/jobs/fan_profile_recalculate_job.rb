class FanProfileRecalculateJob < ApplicationJob
  queue_as :analytics

  def perform(fan_id, creator_id, action, properties = {})
    return if fan_id == creator_id

    profile = FanProfile.find_or_initialize_by(fan_id: fan_id, creator_id: creator_id)
    profile.first_interaction_at ||= Time.current
    profile.last_interaction_at = Time.current

    case action.to_s
    when "collection_unlock"
      profile.collections_owned += 1
      amount = properties["amount_cents"] || properties[:amount_cents] || 0
      profile.total_spent_cents += amount.to_i
    when "post_like"
      profile.likes_given += 1
    when "post_unlike"
      profile.likes_given = [profile.likes_given - 1, 0].max
    when "post_comment"
      profile.comments_given += 1
    when "message_send"
      profile.messages_sent += 1
    when "profile_view"
      profile.profile_visits += 1
    when "live_join"
      profile.live_watches += 1
    when "share"
      profile.shares_made += 1
    when "spoil_me_gift", "live_gift"
      amount = properties["amount_cents"] || properties[:amount_cents] || 0
      profile.gifts_given_cents = (profile.gifts_given_cents || 0) + amount.to_i
      profile.total_spent_cents += amount.to_i
    when "subscribe"
      profile.is_close_friend = true
      profile.close_friend_since ||= Time.current
      profile.months_subscribed = [profile.months_subscribed + 1, 1].max
      amount = properties["amount_cents"] || properties[:amount_cents] || 0
      profile.total_spent_cents += amount.to_i
    when "subscribe_expire"
      profile.is_close_friend = false
    end

    profile.save!
    profile.recalculate_score!
  rescue StandardError => e
    Rails.logger.error("[FanProfileRecalculateJob] Error: #{e.message}")
  end
end
