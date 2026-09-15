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

ActiveRecord::Schema[8.0].define(version: 2026_09_05_011000) do
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
    t.index ["claimant_id", "purchasable_type", "purchasable_id"], name: "index_payment_claims_on_claimant_and_purchasable"
    t.index ["claimant_id"], name: "index_payment_claims_on_claimant_id"
    t.index ["creator_id", "status"], name: "index_payment_claims_on_creator_id_and_status"
    t.index ["creator_id", "utr"], name: "index_payment_claims_unique_utr_per_creator", unique: true, where: "(utr IS NOT NULL)"
    t.index ["creator_id"], name: "index_payment_claims_on_creator_id"
    t.index ["purchasable_type", "purchasable_id"], name: "index_payment_claims_on_purchasable"
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

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["handle"], name: "index_users_on_handle", unique: true
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
  add_foreign_key "creator_blocks", "users", column: "creator_id"
  add_foreign_key "creator_post_comments", "creator_posts"
  add_foreign_key "creator_post_comments", "users"
  add_foreign_key "creator_post_likes", "creator_posts"
  add_foreign_key "creator_post_likes", "users"
  add_foreign_key "creator_posts", "users"
  add_foreign_key "creator_subscriptions", "subscription_plans"
  add_foreign_key "creator_subscriptions", "users", column: "subscriber_id"
  add_foreign_key "gift_contributions", "users", column: "giver_id"
  add_foreign_key "gift_contributions", "wishlist_items"
  add_foreign_key "link_clicks", "product_links"
  add_foreign_key "link_collections", "users"
  add_foreign_key "media_purchases", "paid_media_posts"
  add_foreign_key "media_purchases", "users", column: "buyer_id"
  add_foreign_key "meet_bookings", "meet_slots"
  add_foreign_key "meet_bookings", "users", column: "attendee_id"
  add_foreign_key "meet_offers", "users"
  add_foreign_key "meet_slots", "meet_offers"
  add_foreign_key "paid_media_collections", "subscription_plans"
  add_foreign_key "paid_media_collections", "users"
  add_foreign_key "paid_media_posts", "paid_media_collections"
  add_foreign_key "paid_media_posts", "subscription_plans"
  add_foreign_key "paid_media_posts", "users"
  add_foreign_key "payment_claims", "users", column: "claimant_id"
  add_foreign_key "payment_claims", "users", column: "creator_id"
  add_foreign_key "payment_claims", "users", column: "reviewed_by_id"
  add_foreign_key "product_links", "link_collections"
  add_foreign_key "product_links", "users"
  add_foreign_key "subscription_plans", "users"
  add_foreign_key "wishlist_items", "wishlists"
  add_foreign_key "wishlists", "users"
end
