class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  layout "admin"
  def index
    @users = User.all
    @traders = User.trader.all
    @pending_traders = User.trader.pending.where.not(confirmed_at: nil)
    @inprogress_traders = User.trader.where(confirmed_at: nil, status: :pending)
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: "Access denied" unless current_user.admin?
  end
end
