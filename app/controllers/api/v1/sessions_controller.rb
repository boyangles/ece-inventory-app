class Api::V1::SessionsController < ApplicationController

  respond_to :json
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }
  swagger_controller :sessions, 'Sessions'

  skip_before_action :verify_authenticity_token

  swagger_api :create do
    summary 'Returns all items'
    notes 'These are some notes for everybody!'
    param :form, :email, :string, :required, "Username"
    param :form, :password, :string, :required, "Password"
    response :unauthorized
    response :requested_range_not_satisfiable
  end

  def create
    user = User.find_by(:email => params[:email])
    puts user.username
    user.status = 'approved'
    if user && user.authenticate(params[:password])
      if user.status_approved?
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