class CreateFeedItems < ActiveRecord::Migration[8.0]
  def change
    create_table :feed_items do |t|
      t.bigint   :fan_id,        null: false
      t.bigint   :creator_id,    null: false
      t.string   :item_type,     null: false
      t.string   :target_type,   null: false
      t.bigint   :target_id,     null: false
      t.float    :score,         default: 0.0, null: false
      t.boolean  :seen,          default: false, null: false
      t.datetime :published_at,  null: false
      t.datetime :created_at,    null: false

      # THE critical index: fan's feed, newest first
      t.index [:fan_id, :published_at], order: { published_at: :desc },
              name: "idx_feed_fan_date"
      # Dedup: one item per fan per target
      t.index [:fan_id, :target_type, :target_id], unique: true,
              name: "idx_feed_fan_target_unique"
      # Cleanup by age
      t.index [:published_at], name: "idx_feed_published_at"
      # Bulk delete on unfollow
      t.index [:fan_id, :creator_id], name: "idx_feed_fan_creator"
    end

    add_foreign_key :feed_items, :users, column: :fan_id
    add_foreign_key :feed_items, :users, column: :creator_id
  end
end
