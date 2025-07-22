class Trader::TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_trader

  def new
    @transaction = Transaction.new(transaction_type: params[:transaction_type] || 'buy')
    
    if params[:asset_symbol].present?
      @price = StockPriceService.latest_price(params[:asset_symbol].upcase)
      unless @price
        flash.now[:alert] = "Price not found for symbol: #{params[:asset_symbol]}"
      end
    end
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)
    @transaction.transaction_type = params[:transaction][:transaction_type]
    @transaction.total_amount = @transaction.quantity * @transaction.price

    if @transaction.transaction_type == "buy"
      handle_buy
    elsif @transaction.transaction_type == "sell"
      handle_sell
    else
      redirect_to trader_dashboard_path, alert: "Invalid transaction type."
    end
  end

  def index
    @transactions = current_user.transactions.order(created_at: :desc)
  end

  private

  def transaction_params
    params.require(:transaction).permit(:asset_symbol, :quantity, :price, :transaction_type)
  end

  def handle_buy
    if @transaction.total_amount > current_user.balance
      @transaction.errors.add(:base, "Insufficient balance.")
      render :new
    elsif @transaction.save
      current_user.update(balance: current_user.balance - @transaction.total_amount)
      redirect_to trader_dashboard_path, notice: "Stock purchased successfully!"
    else
      render :new
    end
  end

  def handle_sell
    holding_qty = current_user.transactions
      .where(asset_symbol: @transaction.asset_symbol)
      .group(:transaction_type)
      .sum(:quantity)

    total_bought = holding_qty["buy"].to_i
    total_sold = holding_qty["sell"].to_i
    current_qty = total_bought - total_sold

    if @transaction.quantity > current_qty
      @transaction.errors.add(:base, "You don't have enough shares to sell.")
      render :new
    elsif @transaction.save
      current_user.update(balance: current_user.balance + @transaction.total_amount)
      redirect_to trader_dashboard_path, notice: "Stock sold successfully!"
    else
      render :new
    end
  end

  def ensure_trader
    redirect_to root_path, alert: "Access denied." unless current_user.trader?
  end
end
