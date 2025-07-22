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
end
