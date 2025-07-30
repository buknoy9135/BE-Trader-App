class Admin::PortfoliosController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  layout "admin"
  def index
  end

  def show
    @trader = User.find(params[:id])
    @holdings = @trader.transactions.group(:asset_symbol).sum(:quantity).select { |_symbol, qty| qty > 0 }
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: "Access denied" unless current_user.admin?
  end

  def record_not_found
    redirect_to admin_users_path, alert: "Record does not exist."
  end
end
