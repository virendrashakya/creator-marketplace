class FeedItemsController < ApplicationController
  before_action :require_user

  def seen
    item = current_user.feed_items.find_by(id: params[:id])
    if item
      item.mark_seen!
      head :ok
    else
      head :not_found
    end
  end
end
