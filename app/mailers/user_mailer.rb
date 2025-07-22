class UserMailer < ApplicationMailer
  default from: "kidmilanoy@gmail.com"

  def trader_approved(user)
    @user = user
    mail(to: @user.email, subject: "Your account is approved — you can now trade")
  end
end
