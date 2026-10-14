# One shareable URL holding a hand-picked list of links: products, videos,
# the creator's own collections. Lives at /:handle/:slug.
class LinkList < ApplicationRecord
  belongs_to :user
  has_many :items, -> { order(:position, :id) }, class_name: "LinkListItem", dependent: :destroy, inverse_of: :link_list
  has_many :payment_claims, dependent: :nullify
  has_one_attached :cover

  RESERVED_SLUGS = %w[follow message spoil-me close-friends c p posts collections shop book].freeze

  before_validation :derive_slug

  validates :title, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 160 }
  validates :slug, presence: true, uniqueness: { scope: :user_id },
                   format: { with: /\A[a-z0-9][a-z0-9-]{0,39}\z/, message: "can use lowercase letters, numbers and dashes" },
                   exclusion: { in: RESERVED_SLUGS, message: "is reserved" }
  validate :socials_are_known

  scope :published, -> { where(published: true) }
  scope :on_profile, -> { published.where(show_on_profile: true) }

  def visible_socials
    user.social_links(only: socials)
  end

  def taps_count
    items.sum(:clicks_count)
  end

  def earned_cents
    payment_claims.approved.sum(:amount_cents)
  end

  def status_label
    return "Off" unless published?

    show_on_profile? ? "Live" : "Hidden"
  end

  # The first image in the list stands in when no cover was uploaded.
  def fallback_image_item
    items.detect { |i| i.image_source.present? }
  end

  private

  def derive_slug
    self.slug = (slug.presence || title).to_s.parameterize[0, 40].to_s.delete_suffix("-")
  end

  def socials_are_known
    unknown = Array(socials) - User::SOCIALS.map(&:first)
    errors.add(:socials, "include an unknown network") if unknown.any?
  end
end
