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

end
