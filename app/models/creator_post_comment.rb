class CreatorPostComment < ApplicationRecord
  belongs_to :creator_post
  belongs_to :user
  validates :body, presence: true, length: { maximum: 500 }

  after_create_commit  :update_counter_async
  after_destroy_commit :update_counter_async

  private

  def update_counter_async
    CounterBufferJob.perform_later("CreatorPost", creator_post_id, "comments_count")
  end
end

