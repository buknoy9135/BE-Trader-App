class Trader::StocksController < ApplicationController
  def index
    @q = params[:q]
    @stocks = STOCK_SYMBOLS.select do |symbol|
      @q.blank? || symbol.downcase.include?(@q.downcase)
  end

    @stock_prices = {}
    @stocks.each do |symbol|
      @stock_prices[symbol] = StockPriceService.latest_price(symbol) || 0
    end
  end
end
