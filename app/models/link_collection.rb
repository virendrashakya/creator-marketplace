class LinkCollection < ApplicationRecord
  belongs_to :user
  has_many :product_links, dependent: :nullify

  validates :name, presence: true, length: { maximum: 60 }
  default_scope { order(:position, :created_at) }
end
