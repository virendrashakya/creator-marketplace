class PaidMediaPostsController < ApplicationController
  before_action :require_user
  before_action :set_post, only: %i[edit update destroy]

  def new
    @paid_media_post = current_user.paid_media_posts.new(currency: "INR", media_type: "image")
  end

  def create
    @paid_media_post = current_user.paid_media_posts.new(post_params)
    if @paid_media_post.save
      redirect_to dashboard_path, notice: "Paid post published."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @paid_media_post.update(post_params)
      redirect_to dashboard_path, notice: "Paid post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @paid_media_post.destroy
    redirect_to dashboard_path, notice: "Paid post removed."
  end

  # Test-mode checkout. Replace this action with Stripe Checkout before production.
  def purchase
    post = PaidMediaPost.where(published: true).find(params[:id])
    return redirect_to(profile_path(post.user.handle), alert: "You cannot purchase your own post.") if post.user == current_user

    purchase = current_user.media_purchases.find_or_initialize_by(paid_media_post: post)
    purchase.assign_attributes(amount_cents: post.price_cents, currency: post.currency, status: "paid", payment_reference: "test_#{SecureRandom.hex(8)}")
    if purchase.save
      redirect_to profile_path(post.user.handle), notice: "Unlocked in test mode — no payment was collected."
    else
      redirect_to profile_path(post.user.handle), alert: purchase.errors.full_messages.to_sentence
    end
  end

  private

  def set_post
    @paid_media_post = current_user.paid_media_posts.find(params[:id])
  end

  def post_params
    params.require(:paid_media_post).permit(:title, :caption, :media, :preview, :media_type, :price_cents, :currency, :published, :paid_media_collection_id, :subscription_plan_id)
  end
end
