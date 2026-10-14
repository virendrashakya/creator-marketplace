class CreatorPost < ApplicationRecord
  belongs_to :user
  # A free post can tease a paid collection; the post page links to it.
  belongs_to :paid_media_collection, optional: true
  has_one_attached :media
  has_many :creator_post_likes, dependent: :destroy
  has_many :creator_post_comments, dependent: :destroy
  validates :body, presence: true, length: { maximum: 2_200 }
  validate :collection_belongs_to_author

  def video?
    media.attached? && media.content_type.to_s.start_with?("video/")
  end

  private

  def collection_belongs_to_author
    return if paid_media_collection.blank? || paid_media_collection.user_id == user_id

    errors.add(:paid_media_collection, "is not yours")
  end
end
