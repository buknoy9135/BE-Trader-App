class Trader::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_approved_trader!

  def index
    @balance = current_user.balance
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
      .select { |_, qty| qty > 0 }

    @recent_transactions = current_user.transactions.order(created_at: :desc).limit(10)
  end


  private

  def ensure_approved_trader!
    user = current_user

    if user.trader? && user.status == "pending"
      sign_out user
      if user.confirmed_at.nil?
        redirect_to new_user_session_path, alert: "Please confirm your email to continue."
      else
        redirect_to new_user_session_path, alert: "Your account is awaiting admin approval."
      end
    elsif !user.trader? || user.status != "approved"
      sign_out user
      redirect_to new_user_session_path, alert: "Access restricted to approved traders only."
    end
  end
end
