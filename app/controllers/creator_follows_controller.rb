class CreatorFollowsController < ApplicationController
  before_action :require_user
  before_action :load_creator

  def create
    return if deny_if_blocked_by(@creator)

    # find_or_create_by, not create: a double tap on a slow connection would
    # otherwise hit the unique index and raise.
    CreatorFollow.find_or_create_by(creator: @creator, follower: current_user)
    redirect_back fallback_location: profile_path(@creator.handle)
  end

  def destroy
    CreatorFollow.find_by(creator: @creator, follower: current_user)&.destroy
    redirect_back fallback_location: profile_path(@creator.handle)
  end

  private

  def load_creator
    @creator = User.find_by!(handle: params[:handle].to_s.downcase)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "That page does not exist."
  end
end
