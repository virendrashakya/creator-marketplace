# Async counter cache update. Instead of relying on Rails' built-in
# `counter_cache: true` (which takes a row-level lock on the parent for
# every like/unlike), this job runs a COUNT(*) and writes the result.
#
# At viral scale (thousands of concurrent likes), this avoids row-lock
# contention on `creator_posts`. The tradeoff is a ~1s counter lag that
# is imperceptible in a social feed.
class CounterBufferJob < ApplicationJob
  queue_as :counters

  retry_on ActiveRecord::Deadlocked, wait: 1.second, attempts: 3
  discard_on ActiveRecord::RecordNotFound

  SUPPORTED = {
    "CreatorPost" => {
      "likes_count"    => -> (id) { CreatorPostLike.where(creator_post_id: id).count },
      "comments_count" => -> (id) { CreatorPostComment.where(creator_post_id: id).count },
      "views_count"    => -> (id) { Event.where(target_type: "CreatorPost", target_id: id, action: "post_view").count },
      "shares_count"   => -> (id) { Event.where(target_type: "CreatorPost", target_id: id, action: "share").count }
    },
    "PaidMediaCollection" => {
      "unlocks_count"  => -> (id) { AccessPurchase.where(purchasable_type: "PaidMediaCollection", purchasable_id: id, status: "paid").count },
      "views_count"    => -> (id) { Event.where(target_type: "PaidMediaCollection", target_id: id, action: "collection_view").count }
    }
  }.freeze

  def perform(model_class, model_id, counter_column)
    counter_fn = SUPPORTED.dig(model_class, counter_column)
    return unless counter_fn

    klass = model_class.constantize
    record = klass.find(model_id)
    new_count = counter_fn.call(model_id)

    record.update_column(counter_column, new_count)
  end
end
