class AccountrequestsController < ApplicationController

  def index
    check_admin_user
    @accountrequests = User.where(:status => "waiting").paginate(page: params[:page], per_page: 10)

    #@user_request_page = User.paginate(page: params[:page], per_page: 10)
    #@user_request_page = User.where(:status => "waiting").page(params[:page])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User request deleted"
    redirect_to accountrequests_path
  end

  def approve_user(user)
    check_admin_user
    UserMailer.confirm_user(user).deliver
    user.activate_user
    flash[:success] = "#{user.username} approved"
    render 'index'
  end

  private
  # Confirms administrator
  def check_admin_user
    redirect_to(root_url) unless current_user && current_user.privilege == 'admin'
  end

end
