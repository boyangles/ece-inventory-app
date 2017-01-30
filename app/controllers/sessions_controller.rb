class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:session][:username].downcase)

    if user && user.authenticate(params[:session][:password])
      # Log in and redirect to the user profile page
      if user.email_confirmed
        if user_approved(user)
          log_in user
          redirect_back_or user
        else
          flash[:error] = 'Your account has not been approved by an administrator'
          render 'new'
        end
      else
        flash.now[:error] = 'Please activate your account by following the
        instructions in the account confirmation email you received to proceed'
        render 'new'
      end
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

  def user_approved(user)
    user.status == 'approved'
  end
end
