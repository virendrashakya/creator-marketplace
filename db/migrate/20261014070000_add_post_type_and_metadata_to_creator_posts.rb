class AddPostTypeAndMetadataToCreatorPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :creator_posts, :post_type, :string, default: "post", null: false
    add_column :creator_posts, :metadata, :jsonb, default: {}, null: false
    add_column :creator_posts, :tags, :string, array: true, default: []
    add_index :creator_posts, :post_type
  end
end
