# Signing in. The phone + WhatsApp code is the front door (sessions#new posts
# to OtpController); email and password stays for accounts made before
# phone sign-in existed.
class SessionsController < ApplicationController
  def new
    redirect_to(current_user.creator? ? dashboard_path : root_path) if signed_in?
  end

  def email; end

  def create
    user = User.find_by(email: params[:email].to_s.downcase.strip)
    if user&.authenticate(params[:password])
      reset_session
      session[:user_id] = user.id
      redirect_to (user.creator? ? dashboard_path : root_path), notice: "Welcome back, #{user.first_name}."
    else
      flash.now[:alert] = "That email or password does not match."
      render :email, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "You have been signed out."
  end
end
