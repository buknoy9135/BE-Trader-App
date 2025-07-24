class Admin::TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  layout "admin"
  def index
    @transactions = Transaction.order(id: :desc)
  end

  def show
    @transaction = Transaction.find(params[:id])
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: "Access denied" unless current_user.admin?
  end
end
