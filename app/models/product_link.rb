class ProductLink < ApplicationRecord
  # Loopback, link-local and private ranges. A creator-supplied destination is
  # redirected to by visitors, so it must not be able to point at the host's
  # own network (cloud metadata endpoints especially).
  INTERNAL_HOSTS = /\A(
    localhost | .*\.localhost |
    0\.0\.0\.0 | 127\.[0-9.]+ |
    10\.[0-9.]+ |
    192\.168\.[0-9.]+ |
    172\.(1[6-9]|2[0-9]|3[01])\.[0-9.]+ |
    169\.254\.[0-9.]+ |
    \[?::1\]? | \[?fc[0-9a-f]{2}:.* | \[?fd[0-9a-f]{2}:.* | \[?fe80:.*
  )\z/xi

  # Returns an error message, or nil when the URL is a safe public http(s) one.
  # Public so `visit` can re-check at redirect time — rows written before this
  # validation existed are still in the database.
  def self.http_url_error(value)
    # Anchored: Rails' `format:` matcher is unanchored, so an embedded newline
    # would otherwise smuggle arbitrary trailing content past a valid prefix.
    return "must be a valid http(s) URL" unless value.to_s.match?(/\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/)

    uri = begin
      URI.parse(value)
    rescue URI::InvalidURIError
      return "must be a valid http(s) URL"
    end

    return "must be a valid http(s) URL" if uri.host.blank?
    return "cannot point at an internal address" if uri.host.match?(INTERNAL_HOSTS)
    return "cannot include a username or password" if uri.userinfo.present?

    nil
  end

  belongs_to :user
  belongs_to :link_collection, optional: true
  has_many :link_clicks, dependent: :delete_all

  validates :title, :url, presence: true
  validate :url_is_public_http, if: -> { url.present? }
  validate :image_url_is_public_http, if: -> { image_url.present? }

  default_scope { order(featured: :desc, position: :asc, created_at: :desc) }

  private

  def url_is_public_http
    message = self.class.http_url_error(url)
    errors.add(:url, message) if message
  end

  def image_url_is_public_http
    message = self.class.http_url_error(image_url)
    errors.add(:image_url, message) if message
  end
end
