class PagesController < ApplicationController
  def home
    flagship = User.find_by(handle: "ananyarao")
    others = User.where(account_type: "creator").where.not(handle: "ananyarao").includes(:product_links, :paid_media_posts).limit(5)
    @creators = [flagship, *others].compact
  end
end
