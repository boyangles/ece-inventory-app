class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  # Editing/updating a user credential only can be done when logged in
  before_action :check_logged_in_user, except: [:new, :create]

  # Check_current_user allows users to edit/update currently. Be aware that any method added to check_current_user will be
  # bypassed by admin privileges
  before_action :check_current_user, only: [:show, :edit, :update]
  before_action :check_manager_or_admin, only: [:index]
  before_action :check_admin_user, only: [:new, :create, :destroy]

  def new
    @user = User.new
  end

  # GET /users
  def index
    @users = User.where(status: 'approved').paginate(page: params[:page], per_page: 10)
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
    @requests = @user.requests.where.not(status: "cart").paginate(page: params[:page], per_page: 10)
  end

  # GET /users/1/edit
  def edit
    #  A   //   B      //  C
    # duke // nonadmin // self ==> unable to edit -- 1
    # duke // nonadmin // other ==> unable to edit -- 1
    # duke // admin   // self ==> unable to edit -- 1
    # duke // admin   // other ==> able to edit -- 0

    # loc  // nonadmin // self ==> able to edit -- 0
    # loc  // nonadmin // other ==> unable to edit -- 1
    # loc  // admin   // self ==> able to edit -- 0
    # loc  // admin   // other ==> able to edit -- 0

    # (A && !B && C) + (A && !B && !C) + (A && B && C) + (!A && !B && !C)
    # = (A && !B) + (A && B && C) + (!A && !B && !C)

    if (User.isDukeEmail?(current_user.email) && !is_admin?) ||
       (User.isDukeEmail?(current_user.email) && is_admin? && current_user?(@user)) ||
       (!User.isDukeEmail?(current_user.email) && !is_admin? && !current_user?(@user))
      flash[:danger] = "Cannot edit account"
      redirect_to @user and return
    end

    @user = User.find(params[:id])
  end

  # POST /users
  def create
    @user = User.new(user_params)

    # TODO: Status is hardcoded for now until we decide what to do with it
    @user.status = "approved"
		@user.curr_user = current_user

    if @user.save
      flash[:success] = "#{@user.username} created"
      redirect_to users_path
    else
      flash.now[:danger] = "Unable to create user! Try again?"
      render action: 'new'
    end
  end

  # PATCH/PUT /users/1
  def update
    @user = User.find(params[:id])
		@user.curr_user = current_user

    if user_params[:password].blank? && !current_user?(@user)
      user_params.delete(:password)
      user_params.delete(:password_confirmation)
    end

    if @user.update_attributes(user_params)
      flash[:success] = "Credentials updated successfully"      
			redirect_to @user
    else
      flash[:danger] = "Unable to edit user"
      render 'edit'
    end
  end

  # DELETE /users/1
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User account deleted!"
    redirect_to users_url
  end

  def auth_token
    @user = User.find(params[:id])
    unless current_user?(@user)
      flash[:danger] = "You are not User with ID #{@user.id}"
      redirect_to current_user
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    # Rails 4+ requires you to whitelist attributes in the controller.
    params.fetch(:user, {}).permit(:username, :email, :password, :password_confirmation, :privilege, :status)
  end

	
end
