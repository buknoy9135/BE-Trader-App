class Trader::FundsController < ApplicationController
  layout "trader"
  def index
    @funds = current_user.funds.order(created_at: :desc)
  end

  def new
    @fund = current_user.funds.build
  end

  def create
    @fund = current_user.funds.build(fund_params)
    if @fund.save
      redirect_to trader_funds_path, notice: "Fund request submitted."
    else
      flash.now[:alert] = "Failed to request fund."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def fund_params
    params.require(:fund).permit(:amount)
  end
end
