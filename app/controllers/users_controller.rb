class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  # Editing/updating a user credential only can be done when logged in
  before_action :check_logged_in_user, except: [:new, :create, :confirm_email]

  # Check_current_user allows users to edit/update currently. Be aware that any method added to check_current_user will be
  # bypassed by admin privileges
  before_action :check_current_user, only: [:show, :edit, :update]
  # Security issue: only admin users can delete users
  before_action :check_admin_user, only: [:destroy , :index, :approve_user]

  # GET /users
  def index
    @users = User.where(status: 1).paginate(page: params[:page], per_page: 10)
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
    @requests = @user.requests.paginate(page: params[:page], per_page: 10)
  end

  # GET /users/new
  def new
    if logged_in?
      redirect_to root_path
    end
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  def create
    @user = User.new(user_params)
    # Set default status and privilege
    @user.status = "waiting"
    @user.privilege = "student"

    if @user.save
      # Tell the UserMailer to send a welcome email after save
      UserMailer.welcome_email(@user).deliver

      # Toggle to log the user in upon sign up
      # log_in @user
      flash[:success] = "Please confirm email"

      redirect_to(root_path)
    else
      flash.now[:danger] = "Unable to create user! Try again?"
      render action: 'new'
    end
  end

  # PATCH/PUT /users/1
  def update
    @user = User.find(params[:id])
    
    if (params[:password].blank? && !current_user?(@user))
      params.delete(:password)
      params.delete(:password_confirmation)
    end

    if @user.update_attributes(user_params)
      flash[:success] = "Credentials updated successfully"
      redirect_to @user
    else
      render 'edit'
    end
  end

  # DELETE /users/1
  def destroy
    user = User.find(params[:id])
    user.update!(status: 0)
    flash[:success] = "User account deactivated!"
    redirect_to users_url
  end

  def confirm_email
    @user = User.find_by_confirm_token(params[:id])
    if @user
      @user.email_activate
      flash[:success] = "Welcome to the ECE Inventory System Your email has been confirmed. An Admin will verify your account shortly."
      redirect_to root_url
    else
      flash[:danger] = "Sorry. User does not exist"
      redirect_to root_url
    end
  end

  def approve_user
    user = User.find(params[:id])
    UserMailer.confirm_user(user).deliver
    activate_user(user)
    flash[:success] = "#{user.username} approved"
    redirect_to accountrequests_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      # Rails 4+ requires you to whitelist attributes in the controller.
      params.fetch(:user, {}).permit(:username, :email, :password, :password_confirmation, :privilege)
    end



end
