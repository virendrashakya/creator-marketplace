# Everything the October redesign needs that the old schema could not hold:
# phone-first accounts, collection-centric selling, link lists, PWA push.
class StudioRedesign < ActiveRecord::Migration[8.0]
  def change
    # Phone-first sign-up. A creator or fan who joins with a WhatsApp OTP has
    # no email, so the column stops being mandatory; the unique index still
    # holds for the rows that have one (Postgres treats NULLs as distinct).
    change_column_null :users, :email, true
    change_table :users, bulk: true do |t|
      t.datetime :phone_verified_at
      t.string :blog_url
      t.string :backup_upi_id
      t.integer :auto_approve_under_cents
      t.boolean :notify_whatsapp_claims, default: false, null: false
      t.datetime :onboarded_at
    end
    add_index :users, :phone_number, unique: true, where: "phone_number IS NOT NULL"

    # Collections are the unit fans buy. The first item by position is the
    # public cover; release_at lets a creator schedule a drop.
    change_table :paid_media_collections, bulk: true do |t|
      t.datetime :release_at
      t.boolean :allow_downloads, default: false, null: false
    end
    add_column :paid_media_posts, :position, :integer, default: 0, null: false
    add_index :paid_media_posts, [ :paid_media_collection_id, :position ]

    # A free post can point at the collection it teases.
    add_reference :creator_posts, :paid_media_collection, foreign_key: true

    create_table :link_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :slug, null: false
      t.string :description
      t.boolean :published, default: true, null: false
      t.boolean :show_on_profile, default: true, null: false
      # Which of the creator's socials appear on this list, by key.
      t.string :socials, array: true, default: [], null: false
      t.integer :opens_count, default: 0, null: false
      t.timestamps
    end
    add_index :link_lists, [ :user_id, :slug ], unique: true

    create_table :link_list_items do |t|
      t.references :link_list, null: false, foreign_key: true
      # url, product_link or collection
      t.string :kind, null: false, default: "url"
      t.string :url
      t.string :title, null: false
      t.string :subtitle
      t.string :image_url
      t.string :price_label
      t.references :product_link, foreign_key: true
      t.references :paid_media_collection, foreign_key: true
      t.integer :position, default: 0, null: false
      t.integer :clicks_count, default: 0, null: false
      t.timestamps
    end
    add_index :link_list_items, [ :link_list_id, :position ]

    # Which list a fan came from, so a list can show what it earned.
    add_reference :payment_claims, :link_list, foreign_key: true

    create_table :otp_codes do |t|
      t.string :phone_number, null: false
      t.string :code_digest, null: false
      t.string :purpose, null: false, default: "sign_in"
      t.datetime :expires_at, null: false
      t.datetime :consumed_at
      t.integer :attempts, default: 0, null: false
      t.timestamps
    end
    add_index :otp_codes, [ :phone_number, :created_at ]

    create_table :push_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :endpoint, null: false
      t.string :p256dh, null: false
      t.string :auth, null: false
      t.timestamps
    end
    add_index :push_subscriptions, :endpoint, unique: true
  end
end
