class Api::V1::UsersController < BaseController
  # TODO: Include actions for #create

  # authentication_actions = [:index, :show, :update, :destroy]

  before_action :authenticate_with_token!
  before_action :auth_by_manager_privilege!, only: [:index]
  before_action :auth_by_admin_privilege!, only: [:new, :create, :update, :destroy]
  before_action -> { auth_by_same_user_or_manager!(params[:id]) }, only: [:show]
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  respond_to :json

  swagger_controller :users, 'Users'

  # authentication_actions.each do |api_action|
  #   swagger_api api_action do
  #     param :header, :Authorization, :required, "Authorization Token"
  #   end
  # end

  swagger_api :index do
    summary 'Returns all Users'
    notes 'These are some notes for everybody!'
    param :query, :page, :integer, :optional, "Page number"
    response :unauthorized
    response :not_acceptable, "The request you made is not acceptable"
    response :requested_range_not_satisfiable
  end

  swagger_api :show do
    summary "Fetches a single user"
    param :path, :id, :integer, :required, "User Id"
    response :ok, "Success", :user
    response :unauthorized
    response :not_acceptable
    response :not_found
  end

  swagger_api :create do
    summary "Creates a new User"
    param :form, :username, :string, :required, "Username"
    param :form, :email, :string, :required, "Email"
    param :form, :password, :string, :required, "Password"
    param :form, :password_confirmation, :string, :required, "Password Confirmation"
    param_list :form, :privilege, :string, :required, "Privilege", [ "admin", "ta", "student" ]
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :update do
    summary "Updates an existing user"
    param :path, :id, :integer, :required, "id"
    param :form, :username, :string, "Username"
    param :form, :email, :string, "Email"
    param :form, :password, :string, "Password"
    param :form, :password_confirmation, :string, "Password Confirmation"
    param_list :form, :privilege, :string , "Privilege", [ "admin", "ta", "student" ]
    response :unauthorized
    response :not_acceptable
  end

  swagger_api :destroy do
    summary "Deletes a user"
    param :path, :id, :integer, :required, "id"
    response :unauthorized
    response :not_acceptable
  end

  def index
    respond_with User.all
  end

  def show
    respond_with User.find(params[:id])
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: 201, location: [:api, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def update
    user = User.find(params[:id])

    if user.update(user_params)
      render json: user, status: 200, location: [:api, user]
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    head 204
  end

  private
    def user_params
      params.permit(:username, :email, :password, :password_confirmation, :privilege)
    end
end
