class TransactionsController < ApplicationController
    before_action :authenticate_user!

    def new
    @transaction = Transaction.new
    end

    def create
    @transaction = current_user.transactions.build(transaction_params)
    @transaction.executed_at = Time.current
    @transaction.status = "executed"

    if @transaction.save
      redirect_to transactions_path, notice: "Transaction successful"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @transactions = current_user.transactions.order(executed_at: :desc)
  end

  private

  def transaction_params
    params.require(:transaction).permit(:asset_symbol, :transaction_type, :quantity, :price)
  end

  def ensure_approved_user
    if current_user.trader? && !current_user.approved?
      redirect_to root_path, alert: "Your account is not approved yet."
    end
  end
end
