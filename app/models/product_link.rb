class ProductLink < ApplicationRecord
  belongs_to :user
  belongs_to :link_collection, optional: true
  has_many :link_clicks, dependent: :delete_all

  validates :title, :url, presence: true
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid http(s) URL" }
  default_scope { order(featured: :desc, position: :asc, created_at: :desc) }
end
