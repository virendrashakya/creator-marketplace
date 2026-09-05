class AddAccountProfileDetailsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :account_type, :string, null: false, default: "creator"
    add_column :users, :pronouns, :string
    add_column :users, :location, :string
    add_column :users, :public_email, :string
    add_column :users, :date_of_birth, :date
  end
end
