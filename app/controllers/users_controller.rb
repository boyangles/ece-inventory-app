class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  # Editing/updating a user credential only can be done when logged in
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  # Security issue: only admin users can delete users
  before_action :admin_user, only: :destroy 

  # GET /users
  # GET /users.json
  def index
    @users = User.paginate(page: params[:page], per_page: 10)
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    # Set default status and privilege
    @user.status = "waiting"
    @user.privilege = "student"

    if @user.save
      # Toggle to log the user in upon sign up
      log_in @user

      flash[:success] = "Welcome to the ECE Inventory family!"
      redirect_to @user
    else
      render 'new'
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Credentials updated successfully"
      redirect_to @user
    else
      render 'edit'
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User account deleted!"
    redirect_to users_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Confirms logged-in user
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Login is required to access page."
        redirect_to login_url
      end
    end

    # Confirms correct user, otherwise redirect to homepage
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms administrator
    def admin_user
      redirect_to(root_url) unless current_user.privilege == "admin"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      # Rails 4+ requires you to whitelist attributes in the controller.
      params.fetch(:user, {}).permit(:username, :email, :password, :password_confirmation, :status)
    end
end
