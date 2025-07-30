class UserMailer < ApplicationMailer
  default from: "kidmilanoy@gmail.com"

  def trader_confirmed(user)
    @user = user
    mail(to: @user.email, subject: "Email Confirmed – Awaiting Approval")
  end

  def trader_approved(user)
    @user = user
    mail(to: @user.email, subject: "Your account is approved — you can now trade")
  end

  def trader_rejected(user)
    @user = user
    mail(to: @user.email, subject: "Your Account Has Been Rejected")
  end

  def trader_banned(user)
    @user = user
    mail(to: @user.email, subject: "Your Account Has Been Banned")
  end

  def trader_unban(user)
    @user = user
    mail(to: @user.email, subject: "Your Account Has Been Re-activated")
  end

  def fund_approved(user, fund)
    @user = user
    @fund = fund
    mail(to: @user.email, subject: "Your Fund Request Has Been Approved")
  end

  def fund_rejected(user, fund)
    @user = user
    @fund = fund
    mail(to: @user.email, subject: "Your Fund Request Has Been Denied")
  end
end
