class AddPhoneAndCreatorBlocks < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :phone_number, :string

    create_table :creator_blocks do |t|
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.string :identifier_type, null: false
      t.string :identifier_value, null: false
      t.string :reason
      t.timestamps
    end
    add_index :creator_blocks, %i[creator_id identifier_type identifier_value], unique: true, name: "index_creator_blocks_unique_identifier"
  end
end
