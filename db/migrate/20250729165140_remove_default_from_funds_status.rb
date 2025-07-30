class RemoveDefaultFromFundsStatus < ActiveRecord::Migration[7.2]
  def change
    change_column_default :funds, :status, from: 0, to: nil
  end
end
