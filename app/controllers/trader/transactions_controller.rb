class Trader::TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_trader
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  layout "trader"

  def index
    @transactions = current_user.transactions.order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  def new
    @transaction = Transaction.new(transaction_type: params[:transaction_type] || "buy", asset_symbol: params[:asset_symbol])

    if params[:asset_symbol].present?
      @price = StockSymbolService.latest_price(params[:asset_symbol].upcase)
      unless @price
        flash.now[:alert] = "Price not found for symbol: #{params[:asset_symbol]}"
      end
    end

    # for stock symbol search function
    @symbols = []
    @query = params[:q]

    if @query.present?
      @symbols = StockSymbolService.symbol_search(@query) || []
    end

    if @transaction.transaction_type == "sell" && @transaction.asset_symbol.present?
      holdings = current_user.transactions
        .where(asset_symbol: @transaction.asset_symbol)
        .group(:transaction_type)
        .sum(:quantity)

      bought = holdings["buy"].to_i
      sold = holdings["sell"].to_i
      owned_qty = bought - sold

      @owned_quantity = owned_qty
    end
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)
    @transaction.transaction_type = params[:transaction][:transaction_type]

    # Always refresh price from API
    latest_price = StockSymbolService.latest_price(@transaction.asset_symbol.upcase)

    if latest_price.nil?
      flash[:alert] = "Failed to fetch latest price for #{@transaction.asset_symbol}."
      render :new and return
    end

    @transaction.price = latest_price
    @transaction.total_amount = @transaction.quantity * @transaction.price

    if @transaction.transaction_type == "buy"
      handle_buy
    elsif @transaction.transaction_type == "sell"
      handle_sell
    else
      redirect_to trader_dashboard_path, alert: "Invalid transaction type."
    end
  end

  private

  def transaction_params
    params.require(:transaction).permit(:asset_symbol, :quantity, :price, :transaction_type)
  end

  def handle_buy
    if insufficient_balance?
      @transaction.errors.add(:base, "Insufficient balance.")
      flash.now[:alert] = @transaction.errors.full_messages.to_sentence
      render :new
    elsif @transaction.save
      deduct_balance
      redirect_to trader_dashboard_path, notice: "Stock purchased successfully!"
    else
      flash.now[:alert] = @transaction.errors.full_messages.to_sentence
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
      flash.now[:alert] = @transaction.errors.full_messages.to_sentence
      render :new
    elsif @transaction.save
      add_balance
      redirect_to trader_dashboard_path, notice: "Stock sold successfully!"
    else
      flash.now[:alert] = @transaction.errors.full_messages.to_sentence
      render :new
    end
  end

  def add_balance
    current_user.update(balance: current_user.balance + @transaction.total_amount)
  end

  def insufficient_balance?
    @transaction.total_amount > current_user.balance
  end

  def deduct_balance
    current_user.update(balance: current_user.balance - @transaction.total_amount)
  end

  def ensure_trader
    redirect_to root_path, alert: "Access denied." unless current_user.trader?
  end

  def record_not_found
    redirect_to trader_transactions_path, alert: "Record does not exist."
  end
end
