class CreateEngagementTables < ActiveRecord::Migration[8.0]
  def change
    # ── Fan profiles (one row per creator↔fan pair) ────────────────────
    create_table :fan_profiles do |t|
      t.bigint   :fan_id,               null: false
      t.bigint   :creator_id,           null: false

      # Spend
      t.integer  :total_spent_cents,    default: 0, null: false
      t.integer  :collections_owned,    default: 0, null: false
      t.integer  :gifts_given_cents,    default: 0, null: false

      # Engagement
      t.integer  :likes_given,          default: 0, null: false
      t.integer  :comments_given,       default: 0, null: false
      t.integer  :messages_sent,        default: 0, null: false
      t.integer  :profile_visits,       default: 0, null: false
      t.integer  :live_watches,         default: 0, null: false
      t.integer  :shares_made,         default: 0, null: false

      # Subscription
      t.boolean  :is_close_friend,      default: false, null: false
      t.datetime :close_friend_since
      t.integer  :months_subscribed,    default: 0, null: false

      # Computed
      t.integer  :engagement_score,     default: 0, null: false
      t.string   :tier,                 default: "lurker", null: false

      t.datetime :first_interaction_at
      t.datetime :last_interaction_at

      t.timestamps

      t.index [:fan_id, :creator_id], unique: true, name: "idx_fan_profiles_unique"
      t.index [:creator_id, :engagement_score], name: "idx_fan_profiles_score",
              order: { engagement_score: :desc }
      t.index [:creator_id, :tier], name: "idx_fan_profiles_tier"
      t.index [:creator_id, :total_spent_cents], name: "idx_fan_profiles_spent",
              order: { total_spent_cents: :desc }
    end
    add_foreign_key :fan_profiles, :users, column: :fan_id
    add_foreign_key :fan_profiles, :users, column: :creator_id

    # ── In-app notifications ──────────────────────────────────────────
    create_table :notifications do |t|
      t.bigint   :user_id,      null: false
      t.bigint   :actor_id
      t.string   :kind,         null: false
      t.string   :target_type
      t.bigint   :target_id
      t.jsonb    :data,         default: {}
      t.datetime :read_at

      t.datetime :created_at, null: false

      t.index [:user_id, :created_at], name: "idx_notifications_user_date",
              order: { created_at: :desc }
      t.index [:user_id], name: "idx_notifications_unread",
              where: "read_at IS NULL"
    end
    add_foreign_key :notifications, :users
    add_foreign_key :notifications, :users, column: :actor_id

    # ── JWT / session tracking ─────────────────────────────────────────
    create_table :user_sessions do |t|
      t.bigint   :user_id
      t.string   :session_token,  null: false
      t.string   :device_type
      t.string   :user_agent
      t.string   :ip_hash
      t.string   :platform
      t.datetime :last_seen_at
      t.datetime :expires_at
      t.datetime :revoked_at

      t.datetime :created_at, null: false

      t.index [:session_token], unique: true, name: "idx_user_sessions_token"
      t.index [:user_id, :last_seen_at], name: "idx_user_sessions_active"
    end
    add_foreign_key :user_sessions, :users
  end
end
