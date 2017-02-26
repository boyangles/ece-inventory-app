class SessionsController < ApplicationController
  before_action :check_logged_out_user, only: [:new, :create]

  def new
  end

  def create
    if request.env['omniauth.auth']
      user = User.find_or_create_by(username: request.env['omniauth.auth']['info']['netid'],
                                    email: request.env['omniauth.auth']['info']['email'])
      # TODO: Hardcoded now to just approve all users through duke net ID.
      user.status = "approved"
      user.password = user.password_confirmation = SecureRandom.urlsafe_base64(n=12)

      user.save!
      log_in(user)
      redirect_back_or user and return
    else
      user = User.where(username: params[:session][:username].downcase).where(status:'approved').take
      if user && user.authenticate(params[:session][:password])
        # Log in and redirect to the user profile page
        log_in user
        redirect_back_or user and return
      else
        # Create an error message with flash.now instead of flash
        flash.now[:danger] = 'Invalid username/password combination'
        render 'new' and return
      end
    end

  end

  def destroy
    log_out
    redirect_to root_url
  end
end
