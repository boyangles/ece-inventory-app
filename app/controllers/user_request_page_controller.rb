class UserRequestPageController < ApplicationController

  def index
    check_admin_user
    @user_request_page = User.where(:status => "waiting").paginate(page: params[:page], per_page: 10)

    #@user_request_page = User.paginate(page: params[:page], per_page: 10)
    #@user_request_page = User.where(:status => "waiting").page(params[:page])
  end

  def approve_user(user)
    check_admin_user
    UserMailer.confirm_user(user).deliver
    user.activate_user
    flash.now[:info] = "#{user.username} approved"
    render 'index'
  end

  # Confirms administrator
  def check_admin_user
    redirect_to(root_url) unless current_user && current_user.privilege == 'admin'
  end

end
