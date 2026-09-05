class AddCreatorMonetizationModels < ActiveRecord::Migration[8.0]
  def change
    create_table :subscription_plans do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :price_cents, null: false
      t.string :currency, null: false, default: "INR"
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    create_table :creator_subscriptions do |t|
      t.references :subscription_plan, null: false, foreign_key: true
      t.references :subscriber, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "active"
      t.datetime :current_period_ends_at
      t.string :payment_reference
      t.timestamps
    end
    add_index :creator_subscriptions, %i[subscription_plan_id subscriber_id], unique: true

    create_table :paid_media_collections do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscription_plan, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :price_cents
      t.string :currency, null: false, default: "INR"
      t.boolean :published, null: false, default: true
      t.timestamps
    end

    add_reference :paid_media_posts, :paid_media_collection, foreign_key: true
    add_reference :paid_media_posts, :subscription_plan, foreign_key: true

    create_table :access_purchases do |t|
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.references :purchasable, polymorphic: true, null: false
      t.integer :amount_cents, null: false
      t.string :currency, null: false
      t.string :status, null: false, default: "paid"
      t.string :payment_reference
      t.timestamps
    end
    add_index :access_purchases, %i[buyer_id purchasable_type purchasable_id], unique: true, name: "index_access_purchases_unique_buyer_purchase"

    create_table :contact_reveals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :label, null: false
      t.text :secret_value, null: false
      t.integer :price_cents, null: false
      t.string :currency, null: false, default: "INR"
      t.boolean :published, null: false, default: true
      t.timestamps
    end

    create_table :meet_offers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :location
      t.integer :price_cents, null: false
      t.string :currency, null: false, default: "INR"
      t.integer :duration_minutes, null: false, default: 30
      t.boolean :published, null: false, default: true
      t.timestamps
    end

    create_table :meet_slots do |t|
      t.references :meet_offer, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.timestamps
    end

    create_table :meet_bookings do |t|
      t.references :meet_slot, null: false, foreign_key: true
      t.references :attendee, null: false, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "paid"
      t.integer :amount_cents, null: false
      t.string :currency, null: false
      t.string :payment_reference
      t.timestamps
    end
    # The reference above already creates the meet_slot index; make it unique.
    remove_index :meet_bookings, :meet_slot_id
    add_index :meet_bookings, :meet_slot_id, unique: true
  end
end
