class CreatePaidMedia < ActiveRecord::Migration[8.0]
  def change
    create_table :paid_media_posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :caption
      t.string :media_url, null: false
      t.string :preview_image_url
      t.string :media_type, null: false, default: "image"
      t.integer :price_cents, null: false
      t.string :currency, null: false, default: "INR"
      t.boolean :published, null: false, default: true
      t.timestamps
    end

    create_table :media_purchases do |t|
      t.references :paid_media_post, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: { to_table: :users }
      t.integer :amount_cents, null: false
      t.string :currency, null: false
      t.string :status, null: false, default: "pending"
      t.string :payment_reference
      t.timestamps
    end
    add_index :media_purchases, %i[paid_media_post_id buyer_id], unique: true
  end
end
