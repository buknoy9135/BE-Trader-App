class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!

  layout "admin"
  def index
    @users = User.all
    @traders = User.trader.all
    @pending_traders = User.trader.pending.where(confirmed_at: nil)
    @confirmed_traders = User.trader.pending.where.not(confirmed_at: nil)
    @approved_traders = User.trader.approved.where.not(confirmed_at: nil)
    @rejected_traders = User.trader.rejected
    @banned_traders = User.trader.banned
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # to bypass email confirmation when creating user account
    if current_user.admin?
      @user.status = :approved
      @user.confirmed_at = Time.current
    end

    if @user.save
      redirect_to admin_user_path(@user), notice: "User was successfully created."
    else
      flash.now[:alert] = "Failed to create user."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "User was successfully updated."
    else
      flash.now[:alert] = "Failed to update user."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_users_path, notice: "User was successfully deleted"
  end

  def confirm
    @user = User.find(params[:id])
    @user.confirmed_at = Time.current if @user.confirmed_at.nil?

    if @user.save(validate: false)
      redirect_back fallback_location: admin_users_path, notice: "User confirmed successfully."
    else
      redirect_to admin_users_path, alert: "Failed to confirm user."
    end
  end

  def approve
    @user = User.find(params[:id])
    @user.status = :approved
    @user.confirmed_at = Time.current if @user.confirmed_at.nil?

    if @user.save(validate: false)
      UserMailer.trader_approved(@user).deliver_now
      redirect_back fallback_location: admin_users_path, notice: "User approved and email sent."
    else
      redirect_to admin_users_path, alert: "Failed to approve user."
    end
  end

  def reject
    @user = User.find(params[:id])
    @user.status = :rejected

    if @user.save(validate: false)
      redirect_back fallback_location: admin_users_path, notice: "User rejected successfully."
    else
      redirect_to admin_users_path, alert: "Failed to reject user."
    end
  end

  def ban
    @user = User.find(params[:id])
    @user.status = :banned

    if @user.save(validate: false)
      redirect_back fallback_location: admin_users_path, notice: "User banned successfully."
    else
      redirect_to admin_users_path, alert: "Failed to ban user."
    end
  end

  private

  def ensure_admin!
    redirect_to root_path, alert: "Access denied" unless current_user.admin?
  end

  def user_params
    permitted = [ :first_name, :last_name, :email, :password, :password_confirmation, :status, :balance ]

    # Only allow setting :role if current_user is the super admin
    permitted << :role if current_user.email == "super-admin@email.com"

    params.require(:user).permit(permitted)
  end
end
