class PaidMediaPostsController < ApplicationController
  before_action :require_user, except: %i[media preview]
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

  # Authorized delivery of the paid file. Views must link here rather than to
  # the Active Storage blob URL, whose signed id is permanent and grants
  # anyone holding it access forever.
  def media
    post = PaidMediaPost.published.find(params[:id])
    return head :forbidden unless post.unlocked_for?(current_user)
    return head :not_found unless post.media.attached?

    deliver post.media
  end

  # The teaser image is intentionally public — it is what a locked visitor sees.
  def preview
    post = PaidMediaPost.published.find(params[:id])
    return head :not_found unless post.preview.attached?

    deliver post.preview
  end

  # Test-mode checkout. Replace this action with a real payment intent +
  # webhook before production; access must be granted by the webhook, not here.
  def purchase
    post = PaidMediaPost.published.find(params[:id])
    return redirect_to(profile_path(post.user.handle), alert: "You cannot purchase your own post.") if post.user == current_user
    return if deny_if_blocked_by(post.user)

    purchase = current_user.media_purchases.find_or_initialize_by(paid_media_post: post)
    purchase.assign_attributes(amount_cents: post.price_cents, currency: post.currency, status: "paid", payment_reference: "test_#{SecureRandom.hex(8)}")
    if purchase.save
      redirect_to profile_path(post.user.handle), notice: "Unlocked in test mode — no payment was collected."
    else
      redirect_to profile_path(post.user.handle), alert: purchase.errors.full_messages.to_sentence
    end
  end

  private

  # Streams from the app for disk storage; hands off a short-lived signed URL
  # once a real object store is configured, so large files skip the app server.
  def deliver(attachment)
    if attachment.service.respond_to?(:url) && !attachment.service.is_a?(ActiveStorage::Service::DiskService)
      redirect_to attachment.url(expires_in: 5.minutes), allow_other_host: true
    else
      send_data attachment.download,
                filename: attachment.filename.to_s,
                type: attachment.content_type,
                disposition: "inline"
    end
  end

  def set_post
    @paid_media_post = current_user.paid_media_posts.find(params[:id])
  end

  def post_params
    params.require(:paid_media_post).permit(:title, :caption, :media, :preview, :media_type, :price_cents, :currency, :published, :paid_media_collection_id, :subscription_plan_id)
  end
end
