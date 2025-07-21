class Transaction < ApplicationRecord
  belongs_to :user

  enum transaction_type: { buy: 0, sell: 1 }

  validates :asset_symbol, :transaction_type, :quantity, :price, presence: true
  validates :quantity, :price, numericality: { greater_than: 0 }

  before_validation :calculate_total_amount
  after_create :update_user_balance_and_holdings

  private

  def calculate_total_amount
    self.total_amount = price * quantity
  end

  def update_user_balance_and_holdings
    if buy?
      if user.balance >= total_amount
        user.balance -= total_amount
        user.save!
      else
        raise ActiveRecord::Rollback, "Insufficient balance"
      end
    elsif sell?
      total_bought = user.transactions.where(asset_symbol: asset_symbol, transaction_type: :buy).sum(:quantity)
      total_sold = user.transactions.where(asset_symbol: asset_symbol, transaction_type: :sell).sum(:quantity)
      owned_quantity = total_bought - total_sold

      if owned_quantity >= quantity
        user.balance += total_amount
        user.save!
      else
        raise ActiveRecord::Rollback, "Insufficient shares to sell"
      end
    end
  end
end
