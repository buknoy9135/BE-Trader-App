class TransactionsController < ApplicationController
	before_action :authenticate_user!

	def new
		@transaction = Transaction.new
	end

	def create
		@transaction = current_user.transactions.new(transaction_params)
		@transaction.transaction_type = "buy"
		@transaction.status = "executed"
		@transaction.executed_at = Time.current

		price = StockPriceService.latest_price(@transaction.asset_symbol)
			if price.nil?
				flash[:alert] = "Unable to fetch stock price."
				render :new and return
			end

		@transaction.price = price
		@transaction.total_amount = price * @transaction.quantity

			if current_user.balance < @transaction.total_amount
				flash[:alert] = "Insufficient funds."
				render :new and return
			end

		ActiveRecord::Base.transaction do
			current_user.update!(balance: current_user.balance - @transaction.total_amount)
			@transaction.save!
		end
			flash[:notice] = "Stock bought successfully!"
			redirect_to transactions_path
		# rescue => e
			flash[:alert] = "Transaction failed: #{e.message}"
			render :new
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
