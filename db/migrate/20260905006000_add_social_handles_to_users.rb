class AddSocialHandlesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :instagram_handle, :string
    add_column :users, :youtube_handle, :string
    add_column :users, :x_handle, :string
    add_column :users, :reddit_handle, :string
    add_column :users, :tiktok_handle, :string
    add_column :users, :website_url, :string
  end
end
