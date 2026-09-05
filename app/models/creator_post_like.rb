class CreatorPostLike < ApplicationRecord
  belongs_to :creator_post
  belongs_to :user
  validates :user_id, uniqueness: { scope: :creator_post_id }
end
