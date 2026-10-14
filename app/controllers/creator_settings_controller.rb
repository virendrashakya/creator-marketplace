# Studio · Settings (5h): profile, socials, and where the money goes.
class CreatorSettingsController < ApplicationController
  before_action :require_user

  def edit
    @user = current_user
    load_extras
  end

  def update
    @user = current_user
    @user.assign_attributes(settings_params)

    # The switch and the amount arrive separately; off means no auto-approval.
    if params.key?(:auto_approve)
      rupees = params[:auto_approve_rupees].to_s.gsub(/[^0-9]/, "")
      @user.auto_approve_under_cents = params[:auto_approve] == "1" && rupees.present? ? rupees.to_i * 100 : nil
    end
    @user.accepts_upi_manual = @user.upi_id.present? || @user.upi_qr.attached? if params.dig(:user, :upi_id)

    if @user.save
      redirect_to creator_settings_path, notice: "Saved."
    else
      load_extras
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def load_extras
    @plans = current_user.subscription_plans.order(:price_cents)
    @wishlists = current_user.wishlists.includes(:wishlist_items).order(:created_at)
    @blocks_count = current_user.creator_blocks.count
  end

  def settings_params
    params.require(:user).permit(:name, :email, :bio, :profile_picture, :banner, :location, :public_email,
                                 :creator_category, :creator_subcategory,
                                 :instagram_handle, :youtube_handle, :x_handle, :reddit_handle, :tiktok_handle, :website_url, :blog_url,
                                 :upi_id, :upi_payee_name, :backup_upi_id, :upi_qr, :notify_whatsapp_claims)
  end
end
