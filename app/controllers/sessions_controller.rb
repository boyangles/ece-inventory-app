class SessionsController < ApplicationController
  before_action :check_logged_out_user, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(username: params[:session][:username].downcase)

    if user && user.authenticate(params[:session][:password])
      # Log in and redirect to the user profile page
      log_in user
      redirect_back_or user
    else
      # Create an error message with flash.now instead of flash
      flash.now[:danger] = 'Invalid username/password combination'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end

  def oauth
    redirect_to sessions_oauth_path
  end

  def show
    render 'oauth'
  end

end
