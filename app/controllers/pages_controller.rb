class PagesController < ApplicationController
  def home
    @creators = User.includes(:product_links).order(created_at: :desc).limit(3)
  end
end
