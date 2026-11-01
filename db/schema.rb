# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_11_01_000000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "access_purchases", force: :cascade do |t|
    t.bigint "buyer_id", null: false
    t.string "purchasable_type", null: false
    t.bigint "purchasable_id", null: false
    t.integer "amount_cents", null: false
    t.string "currency", null: false
    t.string "status", default: "paid", null: false
    t.string "payment_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id", "purchasable_type", "purchasable_id"], name: "index_access_purchases_unique_buyer_purchase", unique: true
    t.index ["buyer_id"], name: "index_access_purchases_on_buyer_id"
    t.index ["purchasable_type", "purchasable_id"], name: "index_access_purchases_on_purchasable"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "contact_reveals", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "label", null: false
    t.text "secret_value", null: false
    t.integer "price_cents", null: false
    t.string "currency", default: "INR", null: false
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contact_reveals_on_user_id"
  end

  create_table "content_daily_stats", force: :cascade do |t|
    t.string "content_type", null: false
    t.bigint "content_id", null: false
    t.bigint "creator_id", null: false
    t.date "date", null: false
    t.integer "views", default: 0, null: false
    t.integer "unique_views", default: 0, null: false
    t.integer "likes", default: 0, null: false
    t.integer "comments", default: 0, null: false
    t.integer "shares", default: 0, null: false
    t.integer "unlocks", default: 0, null: false
    t.integer "revenue_cents", default: 0, null: false
    t.integer "taps", default: 0, null: false
    t.integer "pay_sheet_opens", default: 0, null: false
    t.integer "utr_submissions", default: 0, null: false
    t.integer "conversions", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["content_type", "content_id", "date"], name: "idx_content_daily_unique", unique: true
    t.index ["creator_id", "date"], name: "idx_content_daily_creator_date"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.bigint "fan_id", null: false
    t.datetime "last_message_at"
    t.integer "creator_unread_count", default: 0, null: false
    t.integer "fan_unread_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id", "fan_id"], name: "index_conversations_on_creator_id_and_fan_id", unique: true
    t.index ["creator_id", "last_message_at"], name: "index_conversations_on_creator_id_and_last_message_at"
    t.index ["creator_id"], name: "index_conversations_on_creator_id"
    t.index ["fan_id", "last_message_at"], name: "index_conversations_on_fan_id_and_last_message_at"
    t.index ["fan_id"], name: "index_conversations_on_fan_id"
  end

  create_table "creator_blocks", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.string "identifier_type", null: false
    t.string "identifier_value", null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id", "identifier_type", "identifier_value"], name: "index_creator_blocks_unique_identifier", unique: true
    t.index ["creator_id"], name: "index_creator_blocks_on_creator_id"
  end

  create_table "creator_daily_stats", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.date "date", null: false
    t.integer "profile_views", default: 0, null: false
    t.integer "unique_visitors", default: 0, null: false
    t.integer "pwa_visitors", default: 0, null: false
    t.integer "web_visitors", default: 0, null: false
    t.integer "collection_views", default: 0, null: false
    t.integer "post_views", default: 0, null: false
    t.integer "post_likes", default: 0, null: false
    t.integer "post_comments", default: 0, null: false
    t.integer "post_shares", default: 0, null: false
    t.integer "media_views", default: 0, null: false
    t.integer "media_downloads", default: 0, null: false
    t.integer "collection_unlocks", default: 0, null: false
    t.integer "collection_revenue_cents", default: 0, null: false
    t.integer "subscription_revenue_cents", default: 0, null: false
    t.integer "gift_revenue_cents", default: 0, null: false
    t.integer "total_revenue_cents", default: 0, null: false
    t.integer "new_followers", default: 0, null: false
    t.integer "unfollows", default: 0, null: false
    t.integer "new_subscribers", default: 0, null: false
    t.integer "expired_subscribers", default: 0, null: false
    t.integer "messages_received", default: 0, null: false
    t.integer "link_list_opens", default: 0, null: false
    t.integer "link_list_taps", default: 0, null: false
    t.integer "link_list_revenue_cents", default: 0, null: false
    t.integer "live_viewers", default: 0, null: false
    t.integer "live_gifts_cents", default: 0, null: false
    t.integer "claims_received", default: 0, null: false
    t.integer "claims_approved", default: 0, null: false
    t.integer "claims_rejected", default: 0, null: false
    t.integer "avg_approval_seconds", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["creator_id", "date"], name: "idx_creator_daily_stats_unique", unique: true
    t.index ["date"], name: "idx_creator_daily_stats_date"
  end

  create_table "creator_follows", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.bigint "follower_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id", "follower_id"], name: "index_creator_follows_on_creator_id_and_follower_id", unique: true
    t.index ["creator_id"], name: "index_creator_follows_on_creator_id"
    t.index ["follower_id", "created_at"], name: "index_creator_follows_on_follower_id_and_created_at"
    t.index ["follower_id"], name: "index_creator_follows_on_follower_id"
  end

  create_table "creator_post_comments", force: :cascade do |t|
    t.bigint "creator_post_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_post_id"], name: "index_creator_post_comments_on_creator_post_id"
    t.index ["user_id"], name: "index_creator_post_comments_on_user_id"
  end

  create_table "creator_post_likes", force: :cascade do |t|
    t.bigint "creator_post_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_post_id", "user_id"], name: "index_creator_post_likes_on_creator_post_id_and_user_id", unique: true
    t.index ["creator_post_id"], name: "index_creator_post_likes_on_creator_post_id"
    t.index ["user_id"], name: "index_creator_post_likes_on_user_id"
  end

  create_table "creator_posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "paid_media_collection_id"
    t.integer "likes_count", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.integer "views_count", default: 0, null: false
    t.integer "shares_count", default: 0, null: false
    t.string "post_type", default: "post", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "tags", default: [], array: true
    t.index ["paid_media_collection_id"], name: "index_creator_posts_on_paid_media_collection_id"
    t.index ["post_type"], name: "index_creator_posts_on_post_type"
    t.index ["user_id"], name: "index_creator_posts_on_user_id"
  end

  create_table "creator_subscriptions", force: :cascade do |t|
    t.bigint "subscription_plan_id", null: false
    t.bigint "subscriber_id", null: false
    t.string "status", default: "active", null: false
    t.datetime "current_period_ends_at"
    t.string "payment_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscriber_id"], name: "index_creator_subscriptions_on_subscriber_id"
    t.index ["subscription_plan_id", "subscriber_id"], name: "idx_on_subscription_plan_id_subscriber_id_a19b2fa207", unique: true
    t.index ["subscription_plan_id"], name: "index_creator_subscriptions_on_subscription_plan_id"
  end

  create_table "direct_messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "sender_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id", "id"], name: "index_direct_messages_on_conversation_id_and_id"
    t.index ["conversation_id"], name: "index_direct_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_direct_messages_on_sender_id"
  end

  create_table "events", primary_key: ["id", "created_at"], options: "PARTITION BY RANGE (created_at)", force: :cascade do |t|
    t.bigserial "id", null: false
    t.bigint "actor_id", null: false
    t.bigint "creator_id"
    t.string "action", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.jsonb "properties", default: {}
    t.string "source"
    t.string "referrer"
    t.string "device_type"
    t.string "ip_hash"
    t.string "session_id"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.index ["actor_id", "action", "created_at"], name: "idx_events_actor_action_date"
    t.index ["creator_id", "action", "created_at"], name: "idx_events_creator_action_date"
    t.index ["session_id"], name: "idx_events_session"
    t.index ["target_type", "target_id", "action"], name: "idx_events_target_action"
  end

  create_table "events_2026_10", primary_key: ["id", "created_at"], options: "INHERITS (events)", force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('events_id_seq'::regclass)" }, null: false
    t.bigint "actor_id", null: false
    t.bigint "creator_id"
    t.string "action", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.jsonb "properties", default: {}
    t.string "source"
    t.string "referrer"
    t.string "device_type"
    t.string "ip_hash"
    t.string "session_id"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.index ["actor_id", "action", "created_at"], name: "events_2026_10_actor_id_action_created_at_idx"
    t.index ["creator_id", "action", "created_at"], name: "events_2026_10_creator_id_action_created_at_idx"
    t.index ["session_id"], name: "events_2026_10_session_id_idx"
    t.index ["target_type", "target_id", "action"], name: "events_2026_10_target_type_target_id_action_idx"
  end

  create_table "events_2026_11", primary_key: ["id", "created_at"], options: "INHERITS (events)", force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('events_id_seq'::regclass)" }, null: false
    t.bigint "actor_id", null: false
    t.bigint "creator_id"
    t.string "action", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.jsonb "properties", default: {}
    t.string "source"
    t.string "referrer"
    t.string "device_type"
    t.string "ip_hash"
    t.string "session_id"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.index ["actor_id", "action", "created_at"], name: "events_2026_11_actor_id_action_created_at_idx"
    t.index ["creator_id", "action", "created_at"], name: "events_2026_11_creator_id_action_created_at_idx"
    t.index ["session_id"], name: "events_2026_11_session_id_idx"
    t.index ["target_type", "target_id", "action"], name: "events_2026_11_target_type_target_id_action_idx"
  end

  create_table "events_2026_12", primary_key: ["id", "created_at"], options: "INHERITS (events)", force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('events_id_seq'::regclass)" }, null: false
    t.bigint "actor_id", null: false
    t.bigint "creator_id"
    t.string "action", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.jsonb "properties", default: {}
    t.string "source"
    t.string "referrer"
    t.string "device_type"
    t.string "ip_hash"
    t.string "session_id"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.index ["actor_id", "action", "created_at"], name: "events_2026_12_actor_id_action_created_at_idx"
    t.index ["creator_id", "action", "created_at"], name: "events_2026_12_creator_id_action_created_at_idx"
    t.index ["session_id"], name: "events_2026_12_session_id_idx"
    t.index ["target_type", "target_id", "action"], name: "events_2026_12_target_type_target_id_action_idx"
  end

  create_table "events_2027_01", primary_key: ["id", "created_at"], options: "INHERITS (events)", force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('events_id_seq'::regclass)" }, null: false
    t.bigint "actor_id", null: false
    t.bigint "creator_id"
    t.string "action", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.jsonb "properties", default: {}
    t.string "source"
    t.string "referrer"
    t.string "device_type"
    t.string "ip_hash"
    t.string "session_id"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.index ["actor_id", "action", "created_at"], name: "events_2027_01_actor_id_action_created_at_idx"
    t.index ["creator_id", "action", "created_at"], name: "events_2027_01_creator_id_action_created_at_idx"
    t.index ["session_id"], name: "events_2027_01_session_id_idx"
    t.index ["target_type", "target_id", "action"], name: "events_2027_01_target_type_target_id_action_idx"
  end

  create_table "events_2027_02", primary_key: ["id", "created_at"], options: "INHERITS (events)", force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('events_id_seq'::regclass)" }, null: false
    t.bigint "actor_id", null: false
    t.bigint "creator_id"
    t.string "action", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.jsonb "properties", default: {}
    t.string "source"
    t.string "referrer"
    t.string "device_type"
    t.string "ip_hash"
    t.string "session_id"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.index ["actor_id", "action", "created_at"], name: "events_2027_02_actor_id_action_created_at_idx"
    t.index ["creator_id", "action", "created_at"], name: "events_2027_02_creator_id_action_created_at_idx"
    t.index ["session_id"], name: "events_2027_02_session_id_idx"
    t.index ["target_type", "target_id", "action"], name: "events_2027_02_target_type_target_id_action_idx"
  end

  create_table "events_2027_03", primary_key: ["id", "created_at"], options: "INHERITS (events)", force: :cascade do |t|
    t.bigint "id", default: -> { "nextval('events_id_seq'::regclass)" }, null: false
    t.bigint "actor_id", null: false
    t.bigint "creator_id"
    t.string "action", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.jsonb "properties", default: {}
    t.string "source"
    t.string "referrer"
    t.string "device_type"
    t.string "ip_hash"
    t.string "session_id"
    t.timestamptz "created_at", default: -> { "now()" }, null: false
    t.index ["actor_id", "action", "created_at"], name: "events_2027_03_actor_id_action_created_at_idx"
    t.index ["creator_id", "action", "created_at"], name: "events_2027_03_creator_id_action_created_at_idx"
    t.index ["session_id"], name: "events_2027_03_session_id_idx"
    t.index ["target_type", "target_id", "action"], name: "events_2027_03_target_type_target_id_action_idx"
  end

  create_table "fan_profiles", force: :cascade do |t|
    t.bigint "fan_id", null: false
    t.bigint "creator_id", null: false
    t.integer "total_spent_cents", default: 0, null: false
    t.integer "collections_owned", default: 0, null: false
    t.integer "gifts_given_cents", default: 0, null: false
    t.integer "likes_given", default: 0, null: false
    t.integer "comments_given", default: 0, null: false
    t.integer "messages_sent", default: 0, null: false
    t.integer "profile_visits", default: 0, null: false
    t.integer "live_watches", default: 0, null: false
    t.integer "shares_made", default: 0, null: false
    t.boolean "is_close_friend", default: false, null: false
    t.datetime "close_friend_since"
    t.integer "months_subscribed", default: 0, null: false
    t.integer "engagement_score", default: 0, null: false
    t.string "tier", default: "lurker", null: false
    t.datetime "first_interaction_at"
    t.datetime "last_interaction_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id", "engagement_score"], name: "idx_fan_profiles_score", order: { engagement_score: :desc }
    t.index ["creator_id", "tier"], name: "idx_fan_profiles_tier"
    t.index ["creator_id", "total_spent_cents"], name: "idx_fan_profiles_spent", order: { total_spent_cents: :desc }
    t.index ["fan_id", "creator_id"], name: "idx_fan_profiles_unique", unique: true
  end

  create_table "feed_items", force: :cascade do |t|
    t.bigint "fan_id", null: false
    t.bigint "creator_id", null: false
    t.string "item_type", null: false
    t.string "target_type", null: false
    t.bigint "target_id", null: false
    t.float "score", default: 0.0, null: false
    t.boolean "seen", default: false, null: false
    t.datetime "published_at", null: false
    t.datetime "created_at", null: false
    t.index ["fan_id", "creator_id"], name: "idx_feed_fan_creator"
    t.index ["fan_id", "published_at"], name: "idx_feed_fan_date", order: { published_at: :desc }
    t.index ["fan_id", "target_type", "target_id"], name: "idx_feed_fan_target_unique", unique: true
    t.index ["published_at"], name: "idx_feed_published_at"
  end

  create_table "gift_contributions", force: :cascade do |t|
    t.bigint "wishlist_item_id", null: false
    t.bigint "giver_id", null: false
    t.integer "amount_cents", null: false
    t.string "message"
    t.string "status", default: "paid", null: false
    t.string "payment_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["giver_id"], name: "index_gift_contributions_on_giver_id"
    t.index ["wishlist_item_id"], name: "index_gift_contributions_on_wishlist_item_id"
  end

  create_table "link_clicks", force: :cascade do |t|
    t.bigint "product_link_id", null: false
    t.string "referrer"
    t.string "ip_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_link_id"], name: "index_link_clicks_on_product_link_id"
  end

  create_table "link_collections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_link_collections_on_user_id"
  end

  create_table "link_list_items", force: :cascade do |t|
    t.bigint "link_list_id", null: false
    t.string "kind", default: "url", null: false
    t.string "url"
    t.string "title", null: false
    t.string "subtitle"
    t.string "image_url"
    t.string "price_label"
    t.bigint "product_link_id"
    t.bigint "paid_media_collection_id"
    t.integer "position", default: 0, null: false
    t.integer "clicks_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_list_id", "position"], name: "index_link_list_items_on_link_list_id_and_position"
    t.index ["link_list_id"], name: "index_link_list_items_on_link_list_id"
    t.index ["paid_media_collection_id"], name: "index_link_list_items_on_paid_media_collection_id"
    t.index ["product_link_id"], name: "index_link_list_items_on_product_link_id"
  end

  create_table "link_lists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.string "slug", null: false
    t.string "description"
    t.boolean "published", default: true, null: false
    t.boolean "show_on_profile", default: true, null: false
    t.string "socials", default: [], null: false, array: true
    t.integer "opens_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "taps_count", default: 0, null: false
    t.integer "earned_cents", default: 0, null: false
    t.index ["user_id", "slug"], name: "index_link_lists_on_user_id_and_slug", unique: true
    t.index ["user_id"], name: "index_link_lists_on_user_id"
  end

  create_table "live_messages", force: :cascade do |t|
    t.bigint "live_session_id", null: false
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "tip_cents", default: 0, null: false
    t.boolean "is_announcement", default: false, null: false
    t.index ["live_session_id", "id"], name: "index_live_messages_on_live_session_id_and_id"
    t.index ["live_session_id"], name: "index_live_messages_on_live_session_id"
    t.index ["user_id"], name: "index_live_messages_on_user_id"
  end

  create_table "live_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.datetime "scheduled_for", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.string "status", default: "scheduled", null: false
    t.string "access", default: "members", null: false
    t.bigint "subscription_plan_id"
    t.string "playback_url"
    t.integer "live_messages_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "chat_enabled", default: true, null: false
    t.boolean "chat_members_only", default: false, null: false
    t.boolean "unlisted", default: false, null: false
    t.boolean "keep_chat_after", default: true, null: false
    t.integer "peak_viewers", default: 0, null: false
    t.integer "unique_viewers", default: 0, null: false
    t.integer "gifts_cents", default: 0, null: false
    t.integer "duration_minutes", default: 60, null: false
    t.string "admission_mode", default: "vip_only", null: false
    t.integer "ticket_price_cents", default: 29900, null: false
    t.string "stream_mode", default: "obs_rtmp", null: false
    t.string "stream_key"
    t.boolean "auto_save_vault", default: true, null: false
    t.boolean "incentive_goal_enabled", default: true, null: false
    t.integer "incentive_goal_cents", default: 1000000, null: false
    t.string "incentive_reward_title"
    t.integer "pay_to_chat_cents", default: 5000, null: false
    t.integer "chat_delay_seconds", default: 10, null: false
    t.boolean "forensic_watermark_enabled", default: true, null: false
    t.boolean "vip_alert_dispatch", default: true, null: false
    t.index ["status", "scheduled_for"], name: "index_live_sessions_on_status_and_scheduled_for"
    t.index ["subscription_plan_id"], name: "index_live_sessions_on_subscription_plan_id"
    t.index ["user_id", "scheduled_for"], name: "index_live_sessions_on_user_id_and_scheduled_for"
    t.index ["user_id"], name: "index_live_sessions_on_user_id"
  end

  create_table "media_purchases", force: :cascade do |t|
    t.bigint "paid_media_post_id", null: false
    t.bigint "buyer_id", null: false
    t.integer "amount_cents", null: false
    t.string "currency", null: false
    t.string "status", default: "pending", null: false
    t.string "payment_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["buyer_id"], name: "index_media_purchases_on_buyer_id"
    t.index ["paid_media_post_id", "buyer_id"], name: "index_media_purchases_on_paid_media_post_id_and_buyer_id", unique: true
    t.index ["paid_media_post_id"], name: "index_media_purchases_on_paid_media_post_id"
  end

  create_table "meet_bookings", force: :cascade do |t|
    t.bigint "meet_slot_id", null: false
    t.bigint "attendee_id", null: false
    t.string "status", default: "paid", null: false
    t.integer "amount_cents", null: false
    t.string "currency", null: false
    t.string "payment_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["attendee_id"], name: "index_meet_bookings_on_attendee_id"
    t.index ["meet_slot_id"], name: "index_meet_bookings_on_meet_slot_id", unique: true
  end

  create_table "meet_offers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "location"
    t.integer "price_cents", null: false
    t.string "currency", default: "INR", null: false
    t.integer "duration_minutes", default: 30, null: false
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_meet_offers_on_user_id"
  end

  create_table "meet_slots", force: :cascade do |t|
    t.bigint "meet_offer_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meet_offer_id"], name: "index_meet_slots_on_meet_offer_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "actor_id"
    t.string "kind", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.jsonb "data", default: {}
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.index ["user_id", "created_at"], name: "idx_notifications_user_date", order: { created_at: :desc }
    t.index ["user_id"], name: "idx_notifications_unread", where: "(read_at IS NULL)"
  end

  create_table "otp_codes", force: :cascade do |t|
    t.string "phone_number", null: false
    t.string "code_digest", null: false
    t.string "purpose", default: "sign_in", null: false
    t.datetime "expires_at", null: false
    t.datetime "consumed_at"
    t.integer "attempts", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone_number", "created_at"], name: "index_otp_codes_on_phone_number_and_created_at"
  end

  create_table "paid_media_collections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "subscription_plan_id"
    t.string "title", null: false
    t.text "description"
    t.integer "price_cents"
    t.string "currency", default: "INR", null: false
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "release_at"
    t.boolean "allow_downloads", default: false, null: false
    t.integer "items_count", default: 0, null: false
    t.integer "unlocks_count", default: 0, null: false
    t.integer "revenue_cents", default: 0, null: false
    t.integer "views_count", default: 0, null: false
    t.boolean "show_on_profile", default: true, null: false
    t.index ["subscription_plan_id"], name: "index_paid_media_collections_on_subscription_plan_id"
    t.index ["user_id"], name: "index_paid_media_collections_on_user_id"
  end

  create_table "paid_media_posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "caption"
    t.string "media_url"
    t.string "preview_image_url"
    t.string "media_type", default: "image", null: false
    t.integer "price_cents"
    t.string "currency", default: "INR", null: false
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "paid_media_collection_id"
    t.bigint "subscription_plan_id"
    t.integer "position", default: 0, null: false
    t.index ["paid_media_collection_id", "position"], name: "idx_on_paid_media_collection_id_position_4c7b84c86c"
    t.index ["paid_media_collection_id"], name: "index_paid_media_posts_on_paid_media_collection_id"
    t.index ["subscription_plan_id"], name: "index_paid_media_posts_on_subscription_plan_id"
    t.index ["user_id"], name: "index_paid_media_posts_on_user_id"
  end

  create_table "payment_claims", force: :cascade do |t|
    t.bigint "claimant_id", null: false
    t.bigint "creator_id", null: false
    t.string "purchasable_type", null: false
    t.bigint "purchasable_id", null: false
    t.integer "amount_cents", null: false
    t.integer "claimed_amount_cents"
    t.string "currency", default: "INR", null: false
    t.string "payment_method", default: "upi_manual", null: false
    t.string "utr"
    t.text "note"
    t.string "status", default: "pending", null: false
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_id"
    t.string "reject_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "link_list_id"
    t.index ["claimant_id", "purchasable_type", "purchasable_id"], name: "index_payment_claims_on_claimant_and_purchasable"
    t.index ["claimant_id"], name: "index_payment_claims_on_claimant_id"
    t.index ["creator_id", "status"], name: "index_payment_claims_on_creator_id_and_status"
    t.index ["creator_id", "utr"], name: "index_payment_claims_unique_utr_per_creator", unique: true, where: "(utr IS NOT NULL)"
    t.index ["creator_id"], name: "index_payment_claims_on_creator_id"
    t.index ["link_list_id"], name: "index_payment_claims_on_link_list_id"
    t.index ["purchasable_type", "purchasable_id"], name: "index_payment_claims_on_purchasable"
  end

  create_table "post_bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "creator_post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_post_id"], name: "index_post_bookmarks_on_creator_post_id"
    t.index ["user_id", "creator_post_id"], name: "index_post_bookmarks_on_user_id_and_creator_post_id", unique: true
    t.index ["user_id"], name: "index_post_bookmarks_on_user_id"
  end

  create_table "product_links", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "link_collection_id"
    t.string "title", null: false
    t.string "url", null: false
    t.string "image_url"
    t.string "merchant"
    t.string "price"
    t.string "description"
    t.boolean "featured", default: false, null: false
    t.integer "position", default: 0, null: false
    t.integer "clicks_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["link_collection_id"], name: "index_product_links_on_link_collection_id"
    t.index ["user_id"], name: "index_product_links_on_user_id"
  end

  create_table "push_subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "endpoint", null: false
    t.string "p256dh", null: false
    t.string "auth", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["endpoint"], name: "index_push_subscriptions_on_endpoint", unique: true
    t.index ["user_id"], name: "index_push_subscriptions_on_user_id"
  end

  create_table "referral_daily_stats", force: :cascade do |t|
    t.bigint "creator_id", null: false
    t.date "date", null: false
    t.string "source", null: false
    t.string "referrer"
    t.integer "visits", default: 0, null: false
    t.integer "unique_visitors", default: 0, null: false
    t.integer "follows", default: 0, null: false
    t.integer "unlocks", default: 0, null: false
    t.integer "revenue_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["creator_id", "date", "source"], name: "idx_referral_daily_unique", unique: true
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "price_cents", null: false
    t.string "currency", default: "INR", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_subscription_plans_on_user_id"
  end

  create_table "user_sessions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "session_token", null: false
    t.string "device_type"
    t.string "user_agent"
    t.string "ip_hash"
    t.string "platform"
    t.datetime "last_seen_at"
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.index ["session_token"], name: "idx_user_sessions_token", unique: true
    t.index ["user_id", "last_seen_at"], name: "idx_user_sessions_active"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.string "handle", null: false
    t.string "password_digest", null: false
    t.string "bio"
    t.string "avatar_url"
    t.string "theme", default: "minimal", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "instagram_handle"
    t.string "youtube_handle"
    t.string "x_handle"
    t.string "reddit_handle"
    t.string "tiktok_handle"
    t.string "website_url"
    t.string "creator_category"
    t.string "creator_subcategory"
    t.string "profile_layout", default: "classic", null: false
    t.string "account_type", default: "creator", null: false
    t.string "pronouns"
    t.string "location"
    t.string "public_email"
    t.date "date_of_birth"
    t.string "phone_number"
    t.string "upi_id"
    t.string "upi_payee_name"
    t.boolean "accepts_upi_manual", default: false, null: false
    t.integer "followers_count", default: 0, null: false
    t.string "posts_heading"
    t.string "media_heading"
    t.string "links_heading"
    t.string "meet_heading"
    t.string "reveal_heading"
    t.text "links_note"
    t.datetime "phone_verified_at"
    t.string "blog_url"
    t.string "backup_upi_id"
    t.integer "auto_approve_under_cents"
    t.boolean "notify_whatsapp_claims", default: false, null: false
    t.datetime "onboarded_at"
    t.integer "collections_count", default: 0, null: false
    t.integer "posts_count", default: 0, null: false
    t.integer "total_earned_cents", default: 0, null: false
    t.integer "monthly_earned_cents", default: 0, null: false
    t.integer "close_friends_count", default: 0, null: false
    t.integer "unread_claims_count", default: 0, null: false
    t.datetime "last_active_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["handle"], name: "index_users_on_handle", unique: true
    t.index ["phone_number"], name: "index_users_on_phone_number", unique: true, where: "(phone_number IS NOT NULL)"
  end

  create_table "wishlist_items", force: :cascade do |t|
    t.bigint "wishlist_id", null: false
    t.string "title", null: false
    t.string "product_url"
    t.string "image_url"
    t.integer "target_cents", null: false
    t.string "currency", default: "INR", null: false
    t.text "note"
    t.string "status", default: "available", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wishlist_id"], name: "index_wishlist_items_on_wishlist_id"
  end

  create_table "wishlists", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_wishlists_on_user_id"
  end

  add_foreign_key "access_purchases", "users", column: "buyer_id"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "contact_reveals", "users"
  add_foreign_key "content_daily_stats", "users", column: "creator_id"
  add_foreign_key "conversations", "users", column: "creator_id"
  add_foreign_key "conversations", "users", column: "fan_id"
  add_foreign_key "creator_blocks", "users", column: "creator_id"
  add_foreign_key "creator_daily_stats", "users", column: "creator_id"
  add_foreign_key "creator_follows", "users", column: "creator_id"
  add_foreign_key "creator_follows", "users", column: "follower_id"
  add_foreign_key "creator_post_comments", "creator_posts"
  add_foreign_key "creator_post_comments", "users"
  add_foreign_key "creator_post_likes", "creator_posts"
  add_foreign_key "creator_post_likes", "users"
  add_foreign_key "creator_posts", "paid_media_collections"
  add_foreign_key "creator_posts", "users"
  add_foreign_key "creator_subscriptions", "subscription_plans"
  add_foreign_key "creator_subscriptions", "users", column: "subscriber_id"
  add_foreign_key "direct_messages", "conversations"
  add_foreign_key "direct_messages", "users", column: "sender_id"
  add_foreign_key "fan_profiles", "users", column: "creator_id"
  add_foreign_key "fan_profiles", "users", column: "fan_id"
  add_foreign_key "feed_items", "users", column: "creator_id"
  add_foreign_key "feed_items", "users", column: "fan_id"
  add_foreign_key "gift_contributions", "users", column: "giver_id"
  add_foreign_key "gift_contributions", "wishlist_items"
  add_foreign_key "link_clicks", "product_links"
  add_foreign_key "link_collections", "users"
  add_foreign_key "link_list_items", "link_lists"
  add_foreign_key "link_list_items", "paid_media_collections"
  add_foreign_key "link_list_items", "product_links"
  add_foreign_key "link_lists", "users"
  add_foreign_key "live_messages", "live_sessions"
  add_foreign_key "live_messages", "users"
  add_foreign_key "live_sessions", "subscription_plans"
  add_foreign_key "live_sessions", "users"
  add_foreign_key "media_purchases", "paid_media_posts"
  add_foreign_key "media_purchases", "users", column: "buyer_id"
  add_foreign_key "meet_bookings", "meet_slots"
  add_foreign_key "meet_bookings", "users", column: "attendee_id"
  add_foreign_key "meet_offers", "users"
  add_foreign_key "meet_slots", "meet_offers"
  add_foreign_key "notifications", "users"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "paid_media_collections", "subscription_plans"
  add_foreign_key "paid_media_collections", "users"
  add_foreign_key "paid_media_posts", "paid_media_collections"
  add_foreign_key "paid_media_posts", "subscription_plans"
  add_foreign_key "paid_media_posts", "users"
  add_foreign_key "payment_claims", "link_lists"
  add_foreign_key "payment_claims", "users", column: "claimant_id"
  add_foreign_key "payment_claims", "users", column: "creator_id"
  add_foreign_key "payment_claims", "users", column: "reviewed_by_id"
  add_foreign_key "post_bookmarks", "creator_posts"
  add_foreign_key "post_bookmarks", "users"
  add_foreign_key "product_links", "link_collections"
  add_foreign_key "product_links", "users"
  add_foreign_key "push_subscriptions", "users"
  add_foreign_key "referral_daily_stats", "users", column: "creator_id"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "subscription_plans", "users"
  add_foreign_key "user_sessions", "users"
  add_foreign_key "wishlist_items", "wishlists"
  add_foreign_key "wishlists", "users"
end
