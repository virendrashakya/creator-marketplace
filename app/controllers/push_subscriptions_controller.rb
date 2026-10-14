# Registers a browser for Web Push. Called from wf.js once the person has
# granted notification permission.
class PushSubscriptionsController < ApplicationController
  before_action :require_user

  def create
    sub = PushSubscription.find_or_initialize_by(endpoint: params[:endpoint].to_s)
    # An endpoint belongs to one browser; if someone else signs in there,
    # the endpoint follows the new person.
    sub.assign_attributes(user: current_user, p256dh: params[:p256dh], auth: params[:auth])
    if sub.save
      head :created
    else
      render json: { errors: sub.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.push_subscriptions.where(endpoint: params[:endpoint].to_s).destroy_all
    head :no_content
  end
end
