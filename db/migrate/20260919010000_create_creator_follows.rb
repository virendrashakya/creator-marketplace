class CreateCreatorFollows < ActiveRecord::Migration[8.0]
  def change
    # A follow is directional: follower -> creator. Both sides point at users,
    # so neither column can be a plain `t.references :user`.
    create_table :creator_follows do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    # One follow per pair. Enforced in the database as well as the model,
    # because a double tap on a slow connection will race the validation.
    add_index :creator_follows, %i[creator_id follower_id], unique: true
    # Listing "who am I following" newest-first.
    add_index :creator_follows, %i[follower_id created_at]

    # Counter cache: the public profile shows this number on every page view,
    # and a COUNT over follows would be a query per visit on the hottest page
    # in the product.
    add_column :users, :followers_count, :integer, null: false, default: 0
  end
end
