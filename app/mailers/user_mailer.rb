class UserMailer < ApplicationMailer

  default from: 'jordan.r.frazier@gmail.com'

  def welcome_email(user)
    @user = user
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end


end
