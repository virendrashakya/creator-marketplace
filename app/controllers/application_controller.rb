class ApplicationController < ActionController::Base
  helper_method :current_user, :signed_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def signed_in?
    current_user.present?
  end

  def require_user
    return if signed_in?

    redirect_to sign_in_path, alert: "Please sign in to continue."
  end

  # A creator blocking someone must stop interaction, not only viewing.
  # Every write aimed at a creator routes through here.
  def deny_if_blocked_by(creator)
    return false unless creator&.blocks?(current_user)

    redirect_back fallback_location: root_path, alert: "You can no longer interact with this creator."
    true
  end
end
