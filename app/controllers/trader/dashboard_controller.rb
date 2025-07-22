class Trader::DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @balance = current_user.balance

    # Calculate holdings: total bought quantity minus total sold quantity per asset_symbol
    @holdings = current_user.transactions
                    .group(:asset_symbol, :transaction_type)
                    .sum(:quantity)
                    .each_with_object(Hash.new(0)) do |((symbol, type), qty), holdings|
                      if type == "buy"
                        holdings[symbol] += qty
                      elsif type == "sell"
                        holdings[symbol] -= qty
                      end
                    end
                    .select { |_, qty| qty > 0 } # only keep positive holdings

    @recent_transactions = current_user.transactions.order(created_at: :desc).limit(10)
  end

end
