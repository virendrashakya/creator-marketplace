class CreateGiftingWishlists < ActiveRecord::Migration[8.0]
  def change
    create_table :wishlists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.boolean :published, null: false, default: true
      t.timestamps
    end

    create_table :wishlist_items do |t|
      t.references :wishlist, null: false, foreign_key: true
      t.string :title, null: false
      t.string :product_url
      t.string :image_url
      t.integer :target_cents, null: false
      t.string :currency, null: false, default: "INR"
      t.text :note
      t.string :status, null: false, default: "available"
      t.timestamps
    end

    create_table :gift_contributions do |t|
      t.references :wishlist_item, null: false, foreign_key: true
      t.references :giver, null: false, foreign_key: { to_table: :users }
      t.integer :amount_cents, null: false
      t.string :message
      t.string :status, null: false, default: "paid"
      t.string :payment_reference
      t.timestamps
    end
  end
end
