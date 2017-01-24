class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
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

        format.html { redirect_to(root_path) }
        #format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        #format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end

    # if @user.save
    #   flash[:success] = "Welcome to the ECE Inventory family!"
    #   redirect_to @user
    # else
    #   render 'new'
    # end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
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
      params.fetch(:user, {}).permit(:username, :email, :privilege, :password, :password_confirmation, :status)
    end

  def confirm_email
    @user = User.find_by_confirm_token(params[:id])
    if @user
      @user.email_activate
      flash[:success] = "Welcome to the ECE Inventory System Your email has been confirmed.
      Please sign in to continue."
      redirect_to signup_url
    else
      flash[:error] = "Sorry. User does not exist"
      redirect_to root_url
    end
  end


end
