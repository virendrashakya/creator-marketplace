class PostBookmark < ApplicationRecord
  belongs_to :user
  belongs_to :creator_post

  validates :user_id, uniqueness: { scope: :creator_post_id }
end
