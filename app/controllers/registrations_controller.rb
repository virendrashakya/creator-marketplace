# Email sign-up predates phone onboarding. Links to /sign_up still exist in
# the wild, so the page forwards to /start; the POST stays for any old form
# still open in someone's tab.
class RegistrationsController < ApplicationController
  def new
    redirect_to start_path
  end

  def create
    @user = User.new(user_params)
    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to onboarding_upi_path, notice: "Your page is ready. Add your UPI ID so fans can pay you."
    else
      redirect_to start_path, alert: @user.errors.full_messages.to_sentence
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :handle, :password, :password_confirmation)
  end
end
