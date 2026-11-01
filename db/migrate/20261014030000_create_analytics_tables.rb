class CreateAnalyticsTables < ActiveRecord::Migration[8.0]
  def change
    # ── Creator daily rollups ──────────────────────────────────────────
    create_table :creator_daily_stats do |t|
      t.bigint  :creator_id,                     null: false
      t.date    :date,                            null: false

      # Traffic
      t.integer :profile_views,                   default: 0, null: false
      t.integer :unique_visitors,                 default: 0, null: false
      t.integer :pwa_visitors,                    default: 0, null: false
      t.integer :web_visitors,                    default: 0, null: false

      # Content engagement
      t.integer :collection_views,                default: 0, null: false
      t.integer :post_views,                      default: 0, null: false
      t.integer :post_likes,                      default: 0, null: false
      t.integer :post_comments,                   default: 0, null: false
      t.integer :post_shares,                     default: 0, null: false
      t.integer :media_views,                     default: 0, null: false
      t.integer :media_downloads,                 default: 0, null: false

      # Revenue
      t.integer :collection_unlocks,              default: 0, null: false
      t.integer :collection_revenue_cents,        default: 0, null: false
      t.integer :subscription_revenue_cents,      default: 0, null: false
      t.integer :gift_revenue_cents,              default: 0, null: false
      t.integer :total_revenue_cents,             default: 0, null: false

      # Audience
      t.integer :new_followers,                   default: 0, null: false
      t.integer :unfollows,                       default: 0, null: false
      t.integer :new_subscribers,                 default: 0, null: false
      t.integer :expired_subscribers,             default: 0, null: false
      t.integer :messages_received,               default: 0, null: false

      # Link lists
      t.integer :link_list_opens,                 default: 0, null: false
      t.integer :link_list_taps,                  default: 0, null: false
      t.integer :link_list_revenue_cents,         default: 0, null: false

      # Lives
      t.integer :live_viewers,                    default: 0, null: false
      t.integer :live_gifts_cents,                default: 0, null: false

      # Payments
      t.integer :claims_received,                 default: 0, null: false
      t.integer :claims_approved,                 default: 0, null: false
      t.integer :claims_rejected,                 default: 0, null: false
      t.integer :avg_approval_seconds,            default: 0, null: false

      t.datetime :created_at, null: false

      t.index [:creator_id, :date], unique: true, name: "idx_creator_daily_stats_unique"
      t.index [:date],                             name: "idx_creator_daily_stats_date"
    end
    add_foreign_key :creator_daily_stats, :users, column: :creator_id

    # ── Per-content daily rollups ──────────────────────────────────────
    create_table :content_daily_stats do |t|
      t.string  :content_type,                    null: false
      t.bigint  :content_id,                      null: false
      t.bigint  :creator_id,                      null: false
      t.date    :date,                            null: false

      t.integer :views,                           default: 0, null: false
      t.integer :unique_views,                    default: 0, null: false
      t.integer :likes,                           default: 0, null: false
      t.integer :comments,                        default: 0, null: false
      t.integer :shares,                          default: 0, null: false
      t.integer :unlocks,                         default: 0, null: false
      t.integer :revenue_cents,                   default: 0, null: false
      t.integer :taps,                            default: 0, null: false

      # Funnel (collections only)
      t.integer :pay_sheet_opens,                 default: 0, null: false
      t.integer :utr_submissions,                 default: 0, null: false
      t.integer :conversions,                     default: 0, null: false

      t.datetime :created_at, null: false

      t.index [:content_type, :content_id, :date], unique: true, name: "idx_content_daily_unique"
      t.index [:creator_id, :date],                               name: "idx_content_daily_creator_date"
    end
    add_foreign_key :content_daily_stats, :users, column: :creator_id

    # ── Referral / source attribution ──────────────────────────────────
    create_table :referral_daily_stats do |t|
      t.bigint  :creator_id,                      null: false
      t.date    :date,                            null: false
      t.string  :source,                          null: false
      t.string  :referrer

      t.integer :visits,                          default: 0, null: false
      t.integer :unique_visitors,                 default: 0, null: false
      t.integer :follows,                         default: 0, null: false
      t.integer :unlocks,                         default: 0, null: false
      t.integer :revenue_cents,                   default: 0, null: false

      t.datetime :created_at, null: false

      t.index [:creator_id, :date, :source], unique: true, name: "idx_referral_daily_unique"
    end
    add_foreign_key :referral_daily_stats, :users, column: :creator_id
  end
end
