class CreatorPostComment < ApplicationRecord
  belongs_to :creator_post
  belongs_to :user
  validates :body, presence: true, length: { maximum: 500 }
end
