class UserRequestPageController < ApplicationController

  def index
    if admin_user
      @user_request_page = User.where(:status => "waiting").paginate(page: params[:page], per_page: 10)
    else
      flash.now[:error] = 'You are not an admin and cannot access this page'
      #redirect_to root_path
      render '/'
    end
    #@user_request_page = User.paginate(page: params[:page], per_page: 10)
    #@user_request_page = User.where(:status => "waiting").page(params[:page])
  end

  def approve_user(user)
    if admin_user
      UserMailer.confirm_user(user).deliver
      user.user_activate
      redirect_to userrequests_path
    else
      flash[:warning] = "You are not admin"
      redirect_to root_path
    end
  end

  # Confirms administrator
  def admin_user
    user = current_user
    user && user.privilege == 'admin'
  end

end
