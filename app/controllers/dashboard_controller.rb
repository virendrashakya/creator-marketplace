class DashboardController < ApplicationController
  before_action :require_user

  def show
    @collections = current_user.link_collections.includes(:product_links)
    @links = current_user.product_links.includes(:link_collection)
    @total_clicks = @links.sum(:clicks_count)
    @paid_posts = current_user.paid_media_posts.includes(:media_purchases).order(created_at: :desc)
    @paid_media_revenue = @paid_posts.sum { |post| post.media_purchases.paid.sum(:amount_cents) }
    @meet_offers = current_user.meet_offers.includes(meet_slots: :meet_booking).order(created_at: :desc)
    @contact_reveals = current_user.contact_reveals.includes(:access_purchases).order(created_at: :desc)
    @pending_claim_count = current_user.received_payment_claims.pending.count
  end
end
