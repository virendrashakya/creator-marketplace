class PagesController < ApplicationController
  def home
    flagship = User.find_by(handle: "ananyarao")
    others = User.where(account_type: "creator").where.not(handle: "ananyarao").includes(:product_links, :paid_media_posts).limit(5)
    @creators = [flagship, *others].compact
  end

  # The service worker's fallback when there is no network and no saved
  # copy of the page that was asked for.
  def offline; end
end
