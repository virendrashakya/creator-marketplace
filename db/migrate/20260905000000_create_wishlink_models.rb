class CreateWishlinkModels < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :handle, null: false
      t.string :password_digest, null: false
      t.string :bio
      t.string :avatar_url
      t.string :theme, null: false, default: "blush"
      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :handle, unique: true

    create_table :link_collections do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.timestamps
    end

    create_table :product_links do |t|
      t.references :user, null: false, foreign_key: true
      t.references :link_collection, foreign_key: true
      t.string :title, null: false
      t.string :url, null: false
      t.string :image_url
      t.string :merchant
      t.string :price
      t.string :description
      t.boolean :featured, null: false, default: false
      t.integer :position, null: false, default: 0
      t.integer :clicks_count, null: false, default: 0
      t.timestamps
    end

    create_table :link_clicks do |t|
      t.references :product_link, null: false, foreign_key: true
      t.string :referrer
      t.string :ip_hash
      t.timestamps
    end
  end
end
