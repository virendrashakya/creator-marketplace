class AddCounterCachesAndColumns < ActiveRecord::Migration[8.0]
  def change
    # ── Users ──────────────────────────────────────────────────────────
    add_column :users, :collections_count,    :integer, default: 0, null: false
    add_column :users, :posts_count,          :integer, default: 0, null: false
    add_column :users, :total_earned_cents,   :integer, default: 0, null: false
    add_column :users, :monthly_earned_cents, :integer, default: 0, null: false
    add_column :users, :close_friends_count,  :integer, default: 0, null: false
    add_column :users, :unread_claims_count,  :integer, default: 0, null: false
    add_column :users, :last_active_at,       :datetime

    # ── Paid media collections ─────────────────────────────────────────
    add_column :paid_media_collections, :items_count,      :integer, default: 0, null: false
    add_column :paid_media_collections, :unlocks_count,    :integer, default: 0, null: false
    add_column :paid_media_collections, :revenue_cents,    :integer, default: 0, null: false
    add_column :paid_media_collections, :views_count,      :integer, default: 0, null: false
    add_column :paid_media_collections, :show_on_profile,  :boolean, default: true, null: false

    # ── Creator posts ──────────────────────────────────────────────────
    add_column :creator_posts, :likes_count,    :integer, default: 0, null: false
    add_column :creator_posts, :comments_count, :integer, default: 0, null: false
    add_column :creator_posts, :views_count,    :integer, default: 0, null: false
    add_column :creator_posts, :shares_count,   :integer, default: 0, null: false

    # ── Link lists ─────────────────────────────────────────────────────
    add_column :link_lists, :taps_count,   :integer, default: 0, null: false
    add_column :link_lists, :earned_cents, :integer, default: 0, null: false

    # ── Live sessions ──────────────────────────────────────────────────
    add_column :live_sessions, :peak_viewers,    :integer, default: 0, null: false
    add_column :live_sessions, :unique_viewers,  :integer, default: 0, null: false
    add_column :live_sessions, :gifts_cents,     :integer, default: 0, null: false
  end
end
