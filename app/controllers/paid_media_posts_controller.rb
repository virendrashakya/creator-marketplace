require_relative "../services/frosted_preview_service"
require_relative "../services/forensic_watermark_service"

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
  # For fans/subscribers, dynamic forensic watermarks are stamped onto images
  # to discourage and trace unauthorized redistribution.
  def media
    post = PaidMediaPost.published.find(params[:id])
    return head :forbidden unless post.unlocked_for?(current_user)
    return head :not_found unless post.media.attached?

    # Creators viewing their own content receive the original pristine media
    if current_user == post.user || post.media_type != "image"
      return deliver post.media
    end

    # Authenticated fans/buyers receive personalized forensic watermarked media
    watermarked_bytes = ForensicWatermarkService.call(post.media, current_user)
    if watermarked_bytes.present?
      response.headers["Cache-Control"] = "private, no-cache, no-store, must-revalidate"
      response.headers["Pragma"] = "no-cache"
      response.headers["Expires"] = "0"
      send_data watermarked_bytes,
                type: "image/jpeg",
                disposition: "inline",
                filename: "#{post.user.handle}-drop-#{post.id}-licensed-to-#{current_user.handle}.jpg"
    else
      deliver post.media
    end
  end

  # The teaser image is intentionally public, but MUST be served as a backend-frosted
  # glass image to guarantee visitors cannot steal or inspect the raw unblurred file.
  def preview
    post = PaidMediaPost.published.find(params[:id])
    attachment = post.preview.attached? ? post.preview : (post.media.attached? && post.media_type == "image" ? post.media : nil)
    return head :not_found unless attachment.present?

    frosted_bytes = FrostedPreviewService.call(attachment)
    if frosted_bytes.present?
      response.headers["Cache-Control"] = "public, max-age=86400, stale-while-revalidate=604800"
      response.headers["ETag"] = %(W/"frosted-#{attachment.blob.key}")
      send_data frosted_bytes,
                type: "image/jpeg",
                disposition: "inline",
                filename: "preview-#{post.id}.jpg"
    else
      send_data fallback_frosted_svg,
                type: "image/svg+xml",
                disposition: "inline",
                filename: "preview-#{post.id}.svg"
    end
  end

  # Test-mode checkout. Replace this action with a real payment intent +
  # webhook before production; access must be granted by the webhook, not here.
  def purchase
    post = PaidMediaPost.published.find(params[:id])
    unless Rails.env.development? || Rails.env.test?
      return redirect_to new_payment_claim_path("PaidMediaPost", post.id), alert: "Please submit UPI payment claim to unlock."
    end
    return redirect_to(profile_path(post.user.handle), alert: "You cannot purchase your own post.") if post.user == current_user
    return if deny_if_blocked_by(post.user)

    purchase = current_user.media_purchases.find_or_initialize_by(paid_media_post: post)
    purchase.assign_attributes(amount_cents: post.price_cents, currency: post.currency, status: "paid", payment_reference: "test_#{SecureRandom.hex(8)}")
    if purchase.save
      redirect_to profile_path(post.user.handle), notice: "Unlocked in test mode. No payment was collected."
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

  def fallback_frosted_svg
    <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="480" height="380" viewBox="0 0 480 380">
        <defs>
          <radialGradient id="frost" cx="50%" cy="50%" r="70%">
            <stop offset="0%" stop-color="#3b1d3f"/>
            <stop offset="50%" stop-color="#1e1026"/>
            <stop offset="100%" stop-color="#0a050e"/>
          </radialGradient>
        </defs>
        <rect width="480" height="380" fill="url(#frost)"/>
        <text x="50%" y="50%" text-anchor="middle" fill="rgba(255,255,255,0.45)" font-family="system-ui, -apple-system, sans-serif" font-size="16" font-weight="700">🔒 VIP Exclusive Teaser</text>
      </svg>
    SVG
  end
end
