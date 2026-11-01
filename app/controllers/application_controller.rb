class ApplicationController < ActionController::Base
  helper_method :current_user, :signed_in?

  private

  def current_user
    return @current_user if defined?(@current_user)

    if session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
    elsif (header = request.headers["Authorization"]).present?
      token = header.to_s.split(" ").last
      if token.present?
        payload = JwtService.decode(token)
        if payload && payload["sub"]
          @current_user = User.find_by(id: payload["sub"])
        else
          session_record = UserSession.active.find_by(session_token: token)
          @current_user = session_record&.user
          session_record&.touch_last_seen! if session_record
        end
      end
    end

    @current_user
  end

  def signed_in?
    current_user.present?
  end

  def require_user
    return if signed_in?

    redirect_to sign_in_path, alert: "Please sign in to continue."
  end

  # Inline editing happens on the creator's own public page, so a save has to
  # come back there rather than to the dashboard. The flag is a bare "1", never
  # a URL: taking a path from the params would be an open redirect, and the
  # only place this is ever allowed to land is the signed-in creator's own
  # profile, which we can build ourselves.
  def inline_edit_redirect(fallback, tab: nil)
    return fallback unless params[:inline].to_s == "1" && current_user

    profile_path(current_user.handle, tab: tab)
  end

  # A creator blocking someone must stop interaction, not only viewing.
  # Every write aimed at a creator routes through here.
  def deny_if_blocked_by(creator)
    return false unless creator&.blocks?(current_user)

    redirect_back fallback_location: root_path, alert: "You can no longer interact with this creator."
    true
  end
end
