class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  # Editing/updating a user credential only can be done when logged in
  before_action :check_logged_in_user, only: [:show, :index, :edit, :update, :destroy]
  before_action :check_current_user, only: [:edit, :update]
  # Security issue: only admin users can delete users
  before_action :check_admin_user, only: [:destroy , :index, :approve_user]

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
  # POST /users.json
  def create
    @user = User.new(user_params)
    # Set default status and privilege
    @user.status = "waiting"
    @user.privilege = "student"

    respond_to do |format|
      if @user.save
        # Tell the UserMailer to send a welcome email after save
        UserMailer.welcome_email(@user).deliver

        # Toggle to log the user in upon sign up
        # log_in @user
        flash[:success] = "Please confirm email"

        format.html { redirect_to(root_path) }
        #format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        #format.json { render json: @user.errors, status: :unprocessable_entity }
      end
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

  def confirm_email
    @user = User.find_by_confirm_token(params[:id])
    if @user
      @user.email_activate
      flash[:success] = "Welcome to the ECE Inventory System Your email has been confirmed. An Admin will verify your account shortly."
      redirect_to root_url
    else
      flash[:error] = "Sorry. User does not exist"
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
      params.fetch(:user, {}).permit(:username, :email, :password, :password_confirmation, :status)
    end



end
