class Api::V1::UsersController < BaseController
  # TODO: Include actions for #create
  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_manager_privilege!, only: [:index]
  before_action :auth_by_admin_privilege!, only: [:create, :update_status, :update_privilege, :destroy]
  before_action :render_404_if_user_unknown, only: [:show, :update_password, :update_privilege, :update_status, :destroy]
  before_action -> { auth_by_same_user_or_manager!(params[:id]) }, only: [:show]
  before_action -> { auth_by_same_user!(params[:id]) }, only: [:update_password]
  before_action -> { auth_by_not_same_user!(params[:id]) }, only: [:update_status, :update_privilege, :destroy]
  before_action :set_user, only: [:show, :update_password, :update_privilege, :update_status, :destroy]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [:update_password, :update_status, :update_privilege].each do |api_action|
    swagger_api api_action do
      param :header, :Authorization, :string, :required, 'Authentication token'
    end
  end

  respond_to :json

  swagger_controller :users, 'Users'

  swagger_api :index do
    summary 'Returns all Users'
    notes 'Search users'
    param :query, :email, :string, :optional, "Email Address"
    param_list :query, :status, :string, :optional, "Approved or Disabled; must be: approved/deactivated", [:deactivated, :approved]
    param_list :query, :privilege, :string, :optional, "User Permission; must be: student/manager/admin", [:student, :manager, :admin]
    response :ok
    response :unauthorized
    response :unprocessable_entity
  end

  swagger_api :show do
    summary "Fetches a single user"
    param :path, :id, :integer, :required, "User ID"
    response :ok, "Success", :user
    response :unauthorized
    response :not_found
  end

  swagger_api :create do
    summary "Creates a local User"
    param :form, 'user[username]', :string, :required, "Username"
    param :form, 'user[email]', :string, :required, "Email"
    param :form, 'user[password]', :string, :required, "Password"
    param :form, 'user[password_confirmation]', :string, :required, "Password Confirmation"
    param_list :form, 'user[privilege]', :string, :required, "Privilege; must be: student/manager/admin", [ "student", "manager", "admin" ]
    param_list :form, 'user[status]', :string, :optional, "Status; must be: approved/deactivated", [ "approved", "deactivated" ]
    response :unauthorized
    response :created
    response :unprocessable_entity
  end

  swagger_api :update_password do
    summary "Updates an existing user password"
    param :path, :id, :integer, :required, "User ID"
    param :form, 'user[password]', :string, :required, "Password"
    param :form, 'user[password_confirmation]', :string, :required, "Password Confirmation"
    response :unauthorized
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :update_status do
    summary "Updates the status of an existing user"
    param :path, :id, :integer, :required, "User ID"
    param_list :form, 'user[status]', :string, :required, "Approved or Disabled; must be: approved/deactivated", [:deactivated, :approved]
    response :unauthorized
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :update_privilege do
    summary "Updates the privilege of an existing user"
    param :path, :id, :integer, :required, "User ID"
    param_list :form, 'user[privilege]', :string, :required, "Privilege; must be: student/manager/admin", [ "student", "manager", "admin" ]
    response :unauthorized
    response :ok
    response :unprocessable_entity
    response :not_found
  end

  swagger_api :destroy do
    summary "Deletes a user"
    param :path, :id, :integer, :required, "id"
    response :unauthorized
    response :no_content
    response :not_found
  end

  def index
    filter_params = params.slice(:email, :status, :privilege)

    render_client_error("Inputted status is not approved/deactivated!", 422) and
        return unless enum_processable?(filter_params[:status], User::STATUS_OPTIONS)
    render_client_error("Inputted privilege is not student/manager/admin!", 422) and
        return unless enum_processable?(filter_params[:privilege], User::PRIVILEGE_OPTIONS)

    render :json => User.filter(filter_params).map {
        |user| {
          :id => user.id,
          :email => user.email,
          :status => user.status,
          :permission => user.privilege
      }
    }
  end

  def show
    render_simple_user(@user, 200)
  end

  def create
    render_client_error("Inputted status is not approved/deactivated!", 422) and
        return unless enum_processable?(user_params[:status], User::STATUS_OPTIONS)
    render_client_error("Inputted privilege is not student/manager/admin!", 422) and
        return unless enum_processable?(user_params[:privilege], User::PRIVILEGE_OPTIONS)

    user = User.new(user_params)
    user[:username] = (user_params[:username].blank?) ? user_params[:email] : user_params[:username]
    user[:status] = (user_params[:status].blank?) ? 'approved' : user_params[:status]

    if user.save
      render_simple_user(user, 201)
    else
      render_client_error(user.errors, 422)
    end
  end

  def update_password
    password_params = user_params.slice(:password, :password_confirmation)

    if @user.update(password_params)
      render json: { message: 'Password Updated!' } , status: 200
    else
      render json: { errors: @user.errors }, status: 422
    end
  end

  def update_status
    status_params = user_params.slice(:status)
    render_client_error("Inputted status is not approved/deactivated!", 422) and
        return unless enum_processable?(status_params[:status], User::STATUS_OPTIONS)

    update_user_and_render(@user, status_params)
  end

  def update_privilege
    privilege_params = user_params.slice(:privilege)
    render_client_error("Inputted privilege is not student/manager/admin!", 422) and
        return unless enum_processable?(privilege_params[:privilege], User::PRIVILEGE_OPTIONS)

    update_user_and_render(@user, privilege_params)
  end

  def destroy
    @user.destroy
    head 204
  end

  private
  def set_user
    @user = User.find(params[:id])
  end

  private
  def render_404_if_user_unknown
      render json: { errors: 'User not found!' }, status: 404 unless
          User.exists?(params[:id])
  end

  private
  def user_params
    params.fetch(:user, {}).permit(:username, :email, :password, :password_confirmation, :privilege, :status)
  end
end
