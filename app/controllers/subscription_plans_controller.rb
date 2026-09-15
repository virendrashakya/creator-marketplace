class SubscriptionPlansController < ApplicationController
  before_action :require_user
  before_action :set_plan, only: %i[edit update destroy]
  def new; @subscription_plan = current_user.subscription_plans.new(currency: "INR"); end
  def create; @subscription_plan = current_user.subscription_plans.new(plan_params); @subscription_plan.save ? (redirect_to(dashboard_path, notice: "Subscription plan created.")) : (render :new, status: :unprocessable_entity); end
  def edit; end
  def update; @subscription_plan.update(plan_params) ? (redirect_to(dashboard_path, notice: "Plan updated.")) : (render :edit, status: :unprocessable_entity); end
  def destroy; @subscription_plan.destroy; redirect_to dashboard_path, notice: "Plan removed."; end
  def subscribe
    plan = SubscriptionPlan.where(active: true).find(params[:id])
    return redirect_to(profile_path(plan.user.handle), alert: "You cannot subscribe to yourself.") if plan.user == current_user
    return if deny_if_blocked_by(plan.user)
    subscription = current_user.creator_subscriptions.find_or_initialize_by(subscription_plan: plan)
    subscription.update!(status: "active", current_period_ends_at: 1.month.from_now, payment_reference: "test_sub_#{SecureRandom.hex(8)}")
    redirect_to profile_path(plan.user.handle), notice: "Subscribed in test mode — no payment was collected."
  end
  private
  def set_plan; @subscription_plan = current_user.subscription_plans.find(params[:id]); end
  def plan_params; params.require(:subscription_plan).permit(:name, :description, :price_cents, :currency, :active); end
end
