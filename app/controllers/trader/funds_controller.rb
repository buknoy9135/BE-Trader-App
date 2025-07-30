class Trader::FundsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_trader
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  layout "trader"
  def index
    @funds = current_user.funds.order(created_at: :desc)
  end

  def show
    @fund = Fund.find(params[:id])
  end

  def new
    @fund = current_user.funds.build
    @fund.fund_type ||= params[:fund_type]
  end

  def create
    @fund = current_user.funds.build(fund_params)
    if @fund.save
      redirect_to trader_funds_path, notice: "Fund request submitted."
    else
      flash.now[:alert] = @fund.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @fund = current_user.funds.find(params[:id])
  end

  def update
    @fund = current_user.funds.find(params[:id])
    if @fund.update(fund_params)
      redirect_to trader_funds_path, notice: "Request updated successfully."
    else
      flash.now[:alert] = "Failed to update request."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def fund_params
    params.require(:fund).permit(:fund_type, :amount, :notes)
  end

  def ensure_trader
    redirect_to root_path, alert: "Access denied." unless current_user.trader?
  end

  def record_not_found
    redirect_to trader_funds_path, alert: "Record does not exist."
  end
end
