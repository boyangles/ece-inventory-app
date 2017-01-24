class UserMailer < ApplicationMailer

  default from: 'me@example.com'

  def welcome_email(user)
    @user = user
    @url  = 'https://spicysoftwareinventory.herokuapp.com/signup'
    mail(to: "#{user.username} <#{user.email}>", subject: 'Confirm Registration: ECE Inventory')
  end


end
