class CreateCreatorPosts < ActiveRecord::Migration[8.0]
  def change
    create_table :creator_posts do |t|
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.boolean :published, null: false, default: true
      t.timestamps
    end

    create_table :creator_post_likes do |t|
      t.references :creator_post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :creator_post_likes, %i[creator_post_id user_id], unique: true

    create_table :creator_post_comments do |t|
      t.references :creator_post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end
  end
end
