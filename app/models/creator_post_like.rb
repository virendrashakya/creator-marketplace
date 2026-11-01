class CreatorPostLike < ApplicationRecord
  belongs_to :creator_post
  belongs_to :user
  validates :user_id, uniqueness: { scope: :creator_post_id }

  after_create_commit  :update_counter_async
  after_destroy_commit :update_counter_async

  private

  def update_counter_async
    CounterBufferJob.perform_later("CreatorPost", creator_post_id, "likes_count")
  end
end

