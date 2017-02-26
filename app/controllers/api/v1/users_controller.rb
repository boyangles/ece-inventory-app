class Api::V1::UsersController < BaseController
  # TODO: Include actions for #create
  before_action :authenticate_with_token!
  before_action :auth_by_approved_status!
  before_action :auth_by_manager_privilege!, only: [:index]
  before_action :auth_by_admin_privilege!, only: [:create, :update_status, :destroy]
  before_action -> { auth_by_same_user_or_manager!(params[:id]) }, only: [:show]
  before_action -> { auth_by_same_user!(params[:id]) }, only: [:update_password]
  before_action -> { auth_by_not_same_user!(params[:id]) }, only: [:update_status]
  before_action :set_user, only: [:show, :destroy]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  [:update_password, :update_status].each do |api_action|
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
    param_list :query, :status, :string, :optional, "Approved or Disabled; must be: approved/waiting", [:waiting, :approved]
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
    param :form, 'user[username]', :string, :optional, "Username"
    param :form, 'user[email]', :string, :required, "Email"
    param :form, 'user[password]', :string, :required, "Password"
    param :form, 'user[password_confirmation]', :string, :required, "Password Confirmation"
    param_list :form, 'user[privilege]', :string, :required, "Privilege; must be: student/manager/admin", [ "student", "manager", "admin" ]
    param_list :form, 'user[status]', :string, :optional, "Status; must be: approved/waiting"
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
  end

  swagger_api :update_status do
    summary "Updates the status of an existing user"
    param :path, :id, :integer, :required, "User ID"
    param_list :form, 'user[status]', :string, :required, "Approved or Disabled; must be: approved/waiting", [:waiting, :approved]
    response :unauthorized
    response :ok
    response :unprocessable_entity
  end

  swagger_api :destroy do
    summary "Deletes a user"
    param :path, :id, :integer, :required, "id"
    response :unauthorized
    response :not_acceptable
  end

  def index
    filter_params = params.slice(:email, :status, :privilege)

    if (!params[:status].blank? && !User::STATUS_OPTIONS.include?(filter_params[:status])) ||
        (!params[:privilege].blank? && !User::PRIVILEGE_OPTIONS.include?(filter_params[:privilege]))
      render json: { errors: "Filter params are not correct as specified!" }, status: 422
    else
      render :json => User.filter(filter_params).map {
          |user| {
            :id => user.id,
            :email => user.email,
            :status => user.status,
            :permission => user.privilege
          }
      }
    end
  end

  def show
    render :json => User.find(params[:id]).instance_eval {
        |user| {
          :id => user.id,
          :email => user.email,
          :status => user.status,
          :permission => user.privilege
      }
    }
  end

  def create
    if (!user_params[:status].blank? && !User::STATUS_OPTIONS.include?(user_params[:status])) ||
        (!user_params[:privilege].blank? && !User::PRIVILEGE_OPTIONS.include?(user_params[:privilege]))
      render json: { errors: "Inputted params (Status or Privilege) are not as specified!" }, status: 422 and return
    end

    user = User.new(user_params)
    user[:username] = (user_params[:username].blank?) ? user_params[:email] : user_params[:username]
    user[:status] = (user_params[:status].blank?) ? 'approved' : user_params[:status]

    if user.save
      render :json => user.instance_eval {
          |u| {
            :id => u.id,
            :email => u.email,
            :status => u.status,
            :permission => u.privilege
        }
      }, status: 201
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def update_password
    password_params = user_params.slice(:password, :password_confirmation)

    user = User.find(params[:id])

    if user.update(password_params)
      render json: { message: 'Password Updated!' } , status: 200
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  def update_status
    status_params = user_params.slice(:status)

    if status_params[:status].blank? || !User::STATUS_OPTIONS.include?(status_params[:status])
      render json: {
          errors: "Inputted status is not approved/waiting!"
      }, status: 422 and return
    end

    user = User.find(params[:id])

    if user.update(status_params)
      render :json => user.instance_eval {
          |u| {
            :id => u.id,
            :email => u.email,
            :status => u.status,
            :permission => u.privilege
        }
      }
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
  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.fetch(:user, {}).permit(:username, :email, :password, :password_confirmation, :privilege, :status)
  end
end
