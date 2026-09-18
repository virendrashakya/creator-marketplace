class CreatorSettingsController < ApplicationController
  before_action :require_user

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(settings_params)
      redirect_to dashboard_path, notice: "Creator profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    params.require(:user).permit(:name, :email, :bio, :avatar_url, :profile_picture, :banner, :account_type, :pronouns, :location, :public_email, :date_of_birth, :creator_category, :creator_subcategory, :theme, :profile_layout, :instagram_handle, :youtube_handle, :x_handle, :reddit_handle, :tiktok_handle, :website_url, :upi_id, :upi_payee_name, :accepts_upi_manual, :upi_qr,
                          # Section headings, so the copy on a creator's public page is
                          # theirs rather than ours. Blank falls back to the default.
                          *User::SECTION_DEFAULTS.keys)
  end
end
