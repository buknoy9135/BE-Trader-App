class AddDefaultToFundsStatus < ActiveRecord::Migration[7.2]
  def change
    change_column_default :funds, :status, from: nil, to: 0
  end
end
