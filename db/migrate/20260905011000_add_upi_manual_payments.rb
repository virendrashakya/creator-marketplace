class AddUpiManualPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :upi_id, :string
    add_column :users, :upi_payee_name, :string
    add_column :users, :accepts_upi_manual, :boolean, null: false, default: false

    create_table :payment_claims do |t|
      t.references :claimant, null: false, foreign_key: { to_table: :users }
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :purchasable, polymorphic: true, null: false
      t.integer :amount_cents, null: false
      t.integer :claimed_amount_cents
      t.string :currency, null: false, default: "INR"
      t.string :payment_method, null: false, default: "upi_manual"
      t.string :utr
      t.text :note
      t.string :status, null: false, default: "pending"
      t.datetime :reviewed_at
      t.bigint :reviewed_by_id
      t.string :reject_reason
      t.timestamps
    end

    # A UTR is unique per creator: the same reference cannot be submitted twice
    # to the same creator, but two creators may legitimately see distinct
    # payments that happen to collide across banks.
    add_index :payment_claims, %i[creator_id utr], unique: true, where: "utr IS NOT NULL", name: "index_payment_claims_unique_utr_per_creator"
    add_index :payment_claims, %i[creator_id status]
    add_index :payment_claims, %i[claimant_id purchasable_type purchasable_id], name: "index_payment_claims_on_claimant_and_purchasable"
    add_foreign_key :payment_claims, :users, column: :reviewed_by_id
  end
end
