class Trader::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_approved_trader!
  def index
  end

  private

  def ensure_approved_trader!
    if current_user.trader? && current_user.status == "pending"
      if current_user.confirmed_at.nil?
        redirect_to root_path, alert: "Please confirm your email to continue."
      else
        redirect_to root_path, alert: "Your account is awaiting admin approval."
      end
    elsif !current_user.trader? || current_user.status != "approved"
      redirect_to root_path, alert: "Access restricted to approved traders only."
    end
  end
end
