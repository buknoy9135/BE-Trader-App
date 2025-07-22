class Transaction < ApplicationRecord
  belongs_to :user

  enum transaction_type: { buy: 0, sell: 1 }

  validates :asset_symbol, :transaction_type, :quantity, :price, presence: true
  validates :quantity, :price, numericality: { greater_than: 0 }

  validate :sufficient_funds_or_shares

  before_validation :calculate_total_amount

  after_create_commit :update_user_balance_and_holdings

  private

  def calculate_total_amount
    self.total_amount = price * quantity
  end

  def sufficient_funds_or_shares
    return unless user

    qty = quantity.to_f
    amt = total_amount.to_f

    if buy?
      if user.balance < amt
        errors.add(:base, "Insufficient balance to complete purchase")
      end
    elsif sell?
      owned = user.total_stock_quantity(asset_symbol)
      if owned < qty
        errors.add(:base, "Not enough shares to sell")
      end
    end
  end

  def update_user_balance_and_holdings
    user.with_lock do
      if buy?
        deduct_balance
      elsif sell?
        add_balance
      end
    end
  end

  def deduct_balance
    user.update!(balance: user.balance - total_amount)
  end

  def add_balance
    user.update!(balance: user.balance + total_amount)
  end
end
