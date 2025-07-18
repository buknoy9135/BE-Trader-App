class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :asset_symbol
      t.integer :transaction_type
      t.decimal :quantity
      t.decimal :price
      t.decimal :total_amount
      t.string :status
      t.datetime :executed_at

      t.timestamps
    end
  end
end
