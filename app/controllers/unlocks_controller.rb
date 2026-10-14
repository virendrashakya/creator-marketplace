# A fan's library (7e): everything they have unlocked, plus what is still
# waiting for approval. It is the PWA's start page, and the service worker
# keeps a copy so it opens offline.
class UnlocksController < ApplicationController
  before_action :require_user

  def index
    me = current_user
    bought_collections = PaidMediaCollection.live.joins(:access_purchases)
                                            .where(access_purchases: { buyer_id: me.id, status: "paid" })
    plan_ids = me.creator_subscriptions.where(status: "active").where("current_period_ends_at > ?", Time.current).select(:subscription_plan_id)
    plan_collections = PaidMediaCollection.live.where(subscription_plan_id: plan_ids)
    @collections = PaidMediaCollection.where(id: bought_collections.select(:id)).or(PaidMediaCollection.where(id: plan_collections.select(:id)))
                                      .includes(:user, paid_media_posts: [ :media_attachment, :preview_attachment ])
                                      .order(updated_at: :desc).to_a
    @drops = PaidMediaPost.published.standalone.joins(:media_purchases)
                          .where(media_purchases: { buyer_id: me.id, status: "paid" })
                          .includes(:user).order(created_at: :desc).to_a
    @pending = me.payment_claims.pending.includes(:creator).newest_first.to_a
    @memberships = me.creator_subscriptions.includes(subscription_plan: :user)
                     .where(status: "active").where("current_period_ends_at > ?", Time.current).to_a
  end
end
