class CreatorPost < ApplicationRecord
  belongs_to :user
  has_one_attached :media
  has_many :creator_post_likes, dependent: :destroy
  has_many :creator_post_comments, dependent: :destroy
  validates :body, presence: true, length: { maximum: 2_200 }
end
