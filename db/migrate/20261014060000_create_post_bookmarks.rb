class CreatePostBookmarks < ActiveRecord::Migration[8.0]
  def change
    create_table :post_bookmarks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :creator_post, null: false, foreign_key: true

      t.timestamps
    end

    add_index :post_bookmarks, [:user_id, :creator_post_id], unique: true
  end
end
