class AccountrequestsController < ApplicationController

  def show
    # why is this being executed?
    #User.find(params[:id]).destroy
    #flash[:success] = "User request deleted"
    #redirect_to accountrequests_path
    flash[:success] = "what the fuck"
    redirect_to users_path
  end

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

  private
  # Confirms administrator
  def check_admin_user
    redirect_to(root_url) unless current_user && current_user.privilege == 'admin'
  end

end
