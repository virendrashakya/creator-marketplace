# Creator sign-up in four steps: phone (6a) and its code (6b), then handle
# (6c), UPI ID (6d), and live (6e). The account is created at the handle
# step, from the phone number the OTP step verified and left in the session.
class OnboardingController < ApplicationController
  CATEGORIES = [ "Saree draping", "Fashion", "GRWM", "Makeup", "Modelling", "Fitness", "Travel", "Lifestyle", "Dance", "Comedy" ].freeze

  before_action :require_verified_or_user, only: %i[profile update_profile]
  before_action :require_user, only: %i[upi update_upi live]

  # 6a.
  def phone
    return redirect_to(current_user.onboarded_at ? dashboard_path : onboarding_profile_path) if signed_in? && current_user.creator?
  end

  # 6c.
  def profile
    @user = current_user || User.new(account_type: "creator")
  end

  def update_profile
    @user = current_user || User.new(account_type: "creator", phone_number: session[:verified_phone],
                                     phone_verified_at: Time.current)
    @user.assign_attributes(profile_params)
    picked = Array(params[:categories]).map(&:to_s) & CATEGORIES
    @user.creator_category = picked.first
    @user.creator_subcategory = picked.drop(1).join(" · ").presence
    @user.account_type = "creator"
    @user.assign_unusable_password

    if @user.save
      unless signed_in?
        reset_session
        session[:user_id] = @user.id
      end
      redirect_to onboarding_upi_path
    else
      render :profile, status: :unprocessable_entity
    end
  end

  # 6d.
  def upi
    @user = current_user
  end

  def update_upi
    @user = current_user
    @user.assign_attributes(params.require(:user).permit(:upi_id, :upi_payee_name))
    @user.accepts_upi_manual = @user.upi_id.present?
    if @user.upi_id.blank?
      @user.errors.add(:upi_id, "is needed so fans can pay you")
      return render(:upi, status: :unprocessable_entity)
    end

    if @user.save
      redirect_to onboarding_live_path
    else
      render :upi, status: :unprocessable_entity
    end
  end

  # 6e.
  def live
    current_user.update_column(:onboarded_at, Time.current) unless current_user.onboarded_at
  end

  private

  def require_verified_or_user
    return if signed_in? || session[:verified_phone].present?

    redirect_to start_path, alert: "Start with your phone number."
  end

  def profile_params
    params.require(:user).permit(:handle, :name)
  end
end
