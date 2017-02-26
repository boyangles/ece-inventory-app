class Api::V1::SessionsController < ApplicationController

  respond_to :json
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  swagger_controller :sessions, 'Sessions'

  swagger_api :create do
    summary 'Login to session'
    notes 'Creates an authentication token'
    param :form, :email, :string, :required, "Email"
    param :form, :password, :string, :required, "Password"
    response :ok
    response :unprocessable_entity
  end

  swagger_api :destroy do
    summary 'Logout of a session'
    notes 'Removes your authorization token'
    param :path, :id, :string, :required, "Authorization Token"
    response :no_content
    response :unprocessable_entity
  end

  def create
    user = User.find_by(:email => params[:email])
    if user && user.authenticate(params[:password])
      if user.status_approved?
        user.generate_authentication_token!
        user.save
        render_user_with_auth_token(user, 200)
      else
        render json: { errors: 'Your account has not been approved by an administrator' }, status: 422
      end
    else
      render json: { errors: 'Invalid username or password' }, status: 422
    end
  end

  def destroy
    user = User.find_by(auth_token: params[:id])

    if user
      user.generate_authentication_token!
      user.save
      head 204
    else
      render json: { errors: 'Invalid authorization token' }, status: 422
    end
  end

end