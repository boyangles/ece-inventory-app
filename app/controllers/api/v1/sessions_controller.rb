class Api::V1::SessionsController < ApplicationController
  def create
    user_password = params[:sess][:password]
    user_email = params[:sess][:email].downcase
    user = user_email.present? && User.find_by(:email => user_email)

    if user && user.authenticate(user_password)
      if user.status_approved?
        log_in user
        user.generate_authentication_token!
        user.save
        render json: user, status: 200, location: [:api, user]
      else
        render json: { errors: 'Your account has not been approved by an administrator' }, status: 422
      end
    else
      render json: { errors: 'Invalid email or password' }, status: 422
    end
  end
end