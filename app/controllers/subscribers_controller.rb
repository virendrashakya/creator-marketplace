class SubscribersController < ApplicationController
  before_action :require_user

  def index
    @plans = current_user.subscription_plans.order(price_cents: :asc)
    @subscriptions = CreatorSubscription.joins(:subscription_plan)
                                        .where(subscription_plans: { user_id: current_user.id })
                                        .includes(:subscriber, :subscription_plan)
                                        .order(created_at: :desc)

    @total_patrons_count = @subscriptions.count
    active_subs = @subscriptions.where(status: "active")
    @active_patrons_count = active_subs.count
    @mrr_cents = active_subs.joins(:subscription_plan).sum("subscription_plans.price_cents")
    @retention_rate = @total_patrons_count.positive? ? ((@active_patrons_count.to_f / @total_patrons_count) * 100).round(1) : 0.0
  end
end
