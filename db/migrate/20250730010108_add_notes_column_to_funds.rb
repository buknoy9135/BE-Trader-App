class AddNotesColumnToFunds < ActiveRecord::Migration[7.2]
  def change
    add_column :funds, :notes, :text, default: "n/a"
  end
end
