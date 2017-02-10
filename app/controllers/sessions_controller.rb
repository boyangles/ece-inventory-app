class SessionsController < ApplicationController
  before_action :check_logged_out_user, only: [:new, :create]

  def new
  end

  def create
    if (!request.env['omniauth.auth'])
      if user && user.authenticate(params[:session][:password])
        # Log in and redirect to the user profile page
        log_in user
        redirect_back_or user
      else
        # Create an error message with flash.now instead of flash
        flash.now[:danger] = 'Invalid username/password combination'
        render 'new'
      end
      flash[:danger] = "This is a local account"
      redirect_to root_url
    else
      user = User.find_or_create_by(email: request.env['omniauth.auth']['info']['email'])
      user.status = "approved"
      user.save(:validate => false)
      log_in(user)
      redirect_back_or user
    end

  end

  def destroy
    log_out
    redirect_to root_url
  end

end
