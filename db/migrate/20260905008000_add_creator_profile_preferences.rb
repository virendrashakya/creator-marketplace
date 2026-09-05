class AddCreatorProfilePreferences < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :creator_category, :string
    add_column :users, :creator_subcategory, :string
    add_column :users, :profile_layout, :string, null: false, default: "classic"
    change_column_default :users, :theme, from: "blush", to: "minimal"
    execute "UPDATE users SET theme = 'minimal' WHERE theme = 'blush'"
  end
end
