class AccountrequestsController < ApplicationController

  def index
    check_admin_user
    @accountrequests = User.where(status: 0, email_confirmed: true).paginate(page: params[:page], per_page: 10)
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User request deleted"
    redirect_to accountrequests_path
  end

end
