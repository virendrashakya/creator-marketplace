# One row in a link list. Three kinds:
#   url         anything pasted in: a product, a video, a blog post
#   product_link one of the creator's Shop items, which keeps its own clicks
#   collection  one of the creator's paid collections, sold through Wishful
class LinkListItem < ApplicationRecord
  KINDS = %w[url product_link collection].freeze

  belongs_to :link_list
  belongs_to :product_link, optional: true
  belongs_to :paid_media_collection, optional: true

  before_validation :fill_from_source

  validates :kind, inclusion: { in: KINDS }
  validates :title, presence: true, length: { maximum: 120 }
  validates :url, presence: true, if: -> { kind == "url" }
  validate :url_is_public_http, if: -> { url.present? }
  validate :image_url_is_public_http, if: -> { image_url.present? }
  validate :sources_belong_to_owner

  def collection? = kind == "collection"

  def host
    return "wishful" if collection?

    URI.parse(destination_url.to_s).host.to_s.delete_prefix("www.")
  rescue URI::InvalidURIError
    ""
  end

  def video?
    host.match?(/youtube\.com|youtu\.be|instagram\.com\/reel/)
  end

  def destination_url
    product_link&.url || url
  end

  # Either a remote URL string or an attachment, for the view to render.
  def image_source
    return paid_media_collection.cover_post if collection? && paid_media_collection&.cover_post
    return product_link.image_url if product_link&.image_url.present?

    image_url.presence
  end

  # "myntra.com · ₹8,999", "youtube.com · video", "On Wishful · 18 photos"
  def meta_label
    if collection?
      "On Wishful · #{paid_media_collection&.contents_label}"
    else
      [ host.presence, (video? ? "video" : price_label.presence) ].compact.join(" · ")
    end
  end

  private

  def fill_from_source
    if product_link
      self.kind = "product_link"
      self.title = title.presence || product_link.title
      self.price_label = price_label.presence || product_link.price
    elsif paid_media_collection
      self.kind = "collection"
      self.title = title.presence || paid_media_collection.title
      self.price_label = paid_media_collection.price_label
    elsif url.present? && title.blank?
      self.title = URI.parse(url).host.to_s.delete_prefix("www.") rescue url
    end
  end

  def url_is_public_http
    message = ProductLink.http_url_error(url)
    errors.add(:url, message) if message
  end

  def image_url_is_public_http
    message = ProductLink.http_url_error(image_url)
    errors.add(:image_url, message) if message
  end

  def sources_belong_to_owner
    owner_id = link_list&.user_id
    errors.add(:product_link, "is not yours") if product_link && product_link.user_id != owner_id
    errors.add(:paid_media_collection, "is not yours") if paid_media_collection && paid_media_collection.user_id != owner_id
  end
end
