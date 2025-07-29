class Trader::PortfolioController < ApplicationController
  before_action :authenticate_user!

  def index
    @holdings = current_user.transactions
      .group("UPPER(asset_symbol)")
      .sum(:quantity)
      .select { |_, qty| qty > 0 }
  end
end
