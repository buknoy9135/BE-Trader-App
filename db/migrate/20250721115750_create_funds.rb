class CreateFunds < ActiveRecord::Migration[7.2]
  def change
    create_table :funds do |t|
      t.decimal :amount
      t.integer :fund_type
      t.integer :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
