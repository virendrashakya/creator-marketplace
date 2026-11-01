# Accumulates intraday stats into content_daily_stats, creator_daily_stats,
# and referral_daily_stats every 15 minutes.
# This gives creators near real-time analytics in Studio without waiting
# for the midnight DailyAnalyticsRollupJob.
class ContentStatsAccumulatorJob < ApplicationJob
  queue_as :analytics

  def perform(target_date = nil)
    date = target_date ? Date.parse(target_date.to_s) : Date.current
    DailyAnalyticsRollupJob.new.perform(date)
  rescue StandardError => e
    Rails.logger.error("[ContentStatsAccumulatorJob] Intraday rollup failed: #{e.message}")
  end
end
