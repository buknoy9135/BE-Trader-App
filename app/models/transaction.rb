class Transaction < ApplicationRecord
  belongs_to :user

  enum transaction_type: { buy: 0, sell: 1 }

  validates :asset_symbol, :transaction_type, :quantity, :price, presence: true
  validates :quantity, :price, numericality: { greater_than: 0 }

  validate :sufficient_funds_or_shares

  before_validation :calculate_total_amount
  before_validation :normalize_asset_symbol

  private

  def normalize_asset_symbol
    self.asset_symbol = asset_symbol.to_s.upcase
  end

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
end
