class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_user, except: [ :index, :new, :create ]
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key

  layout "admin"
  def index
    base_scope = current_user.super_admin? ? User.all : User.traders

    if params[:q]&.[](:status_eq).present?
      status_key = params[:q][:status_eq]
      enum_value = User.statuses[status_key]
      params[:q][:status_eq] = enum_value if enum_value
    end

    @q = base_scope.ransack(params[:q])
    @users = @q.result(distinct: true).page(params[:page]).per(10)

    @pending_traders   = User.pending_traders.page(params[:page]).per(10)
    @confirmed_traders = User.confirmed_traders.page(params[:page]).per(10)
    @approved_traders  = User.approved_traders.page(params[:page]).per(10)
    @rejected_traders  = User.rejected_traders.page(params[:page]).per(10)
    @banned_traders    = User.banned_traders.page(params[:page]).per(10)
  end

  def show; end

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

  def edit;  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "User was successfully updated."
    else
      flash.now[:alert] = "Failed to update user."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if current_user.email == "super-admin@email.com"
      ActiveRecord::Base.transaction do
        @user.funds.destroy_all
        @user.transactions.destroy_all
        @user.destroy!
      end
      redirect_to admin_users_path, notice: "User and all associated records have been force deleted."
    else
      if @user.funds.exists? || @user.transactions.exists?
        redirect_to admin_users_path, alert: "You can't delete a user with existing funds or transactions."
      else
        @user.destroy
        redirect_to admin_users_path, notice: "User deleted."
      end
    end
  end

  def confirm
    if @user.confirmed_at.nil?
      @user.confirmed_at ||= Time.current
      @user.status = :pending

      if @user.save(validate: false)
        UserMailer.trader_confirmed(@user).deliver_now
        redirect_back fallback_location: admin_users_path, notice: "User confirmed and email sent."
      else
        redirect_to admin_users_path, alert: "Failed to confirm user."
      end
    else
      redirect_back fallback_location: admin_users_path, alert: "Only unconfirmed users can be confirmed."
    end
  end

  def approve
    if @user.confirmed_at.present?
      @user.status = :approved
      @user.confirmed_at = @user.confirmed_at || Time.current

      if @user.save(validate: false)
        UserMailer.trader_approved(@user).deliver_now
        redirect_back fallback_location: admin_users_path, notice: "User approved and email sent."
      else
        redirect_to admin_users_path, alert: "Failed to approve user."
      end
    else
      redirect_back fallback_location: admin_users_path, alert: "Only confirmed users can be approved."
    end
  end

  def reject
    @user.status = :rejected
    @user.confirmed_at ||= Time.current

    if @user.save(validate: false)
      UserMailer.trader_rejected(@user).deliver_now
      redirect_back fallback_location: admin_users_path, notice: "User rejected and email sent."
    else
      redirect_to admin_users_path, alert: "Failed to reject user."
    end
  end

  def ban
    if @user.approved?
      @user.status = :banned

      if @user.save(validate: false)
        UserMailer.trader_banned(@user).deliver_now
        redirect_back fallback_location: admin_users_path, notice: "User banned and email sent."
      else
        redirect_to admin_users_path, alert: "Failed to ban user."
      end
    else
      redirect_back fallback_location: admin_users_path, alert: "Only approved users can be banned."
    end
  end

  def unban
    if @user.banned?
      @user.status = :approved

      if @user.save(validate: false)
        UserMailer.trader_unban(@user).deliver_now
        redirect_back fallback_location: admin_users_path, notice: "User account re-activated and email sent."
      else
        redirect_to admin_users_path, alert: "Failed to re-activate user account."
      end
    else
      redirect_back fallback_location: admin_users_path, alert: "Only banned users account can be re-activated."
    end
  end

  def resend_confirmation
    if @user.confirmed_at.nil? && @user.pending?
      @user.send_confirmation_instructions
      redirect_back fallback_location: admin_users_path, notice: "Confirmation email resent to #{@user.email}."
    else
      redirect_back fallback_location: admin_users_path, alert: "Cannot resend. User may already be confirmed or not pending."
    end
  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_admin!
    redirect_to root_path, alert: "Access denied" unless current_user.admin?
  end

  def user_params
    permitted = [ :first_name, :last_name, :email, :password, :password_confirmation, :status, :balance ]

    # Only allow setting :role if current_user is the super admin
    permitted << :role if current_user.email == "super-admin@email.com"

    params.require(:user).permit(permitted)
  end

  def record_not_found
    redirect_to admin_users_path, alert: "Record does not exist."
  end

  def invalid_foreign_key
    redirect_to admin_portfolio_path, alert: "Unable to delete user. User is still referenced to transaction(s)."
  end
end
