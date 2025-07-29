class Admin::TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key

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

  def record_not_found
    redirect_to admin_users_path, alert: "Record does not exist."
  end

  def invalid_foreign_key
    redirect_to admin_portfolio_path, alert: "Unable to delete user. User is still referenced to transaction(s)."
  end
end
