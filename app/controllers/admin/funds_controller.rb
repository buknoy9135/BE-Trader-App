class Admin::FundsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  layout "admin"
  def index
    @funds = Fund.pending.order(created_at: :desc)
    @all_funds = Fund.all
  end

  def show
    @fund = Fund.find(params[:id])
  end

  def approve
    @fund = Fund.find(params[:id])
    if @fund.can_be_approved?
      @fund.apply_to_user_balance!
      @fund.update(status: :approved)
      UserMailer.fund_approved(@fund.user, @fund).deliver_now
      redirect_back fallback_location: admin_funds_path, notice: "Approved and reflected to trader balance. Email sent to trader."
    else
      redirect_to admin_funds_path, alert: "Cannot approve this fund request"
    end
  end

  def reject
    @fund = Fund.find(params[:id])
    if @fund.update(status: :rejected)
      UserMailer.fund_rejected(@fund.user, @fund).deliver_now
      redirect_back fallback_location: admin_funds_path, notice: "Fund request has been rejected. Email sent to trader."
    else
      redirect_to admin_funds_path, alert: "Failed to reject fund request."
    end
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: "Access denied" unless current_user.admin?
  end

  def record_not_found
    redirect_to admin_users_path, alert: "Record does not exist."
  end
end
