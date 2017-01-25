class UserRequestPageController < ApplicationController

  def index
    if current_user.privilege == "admin"
      @user_request_page = User.where(:status => "waiting").paginate(page: params[:page], per_page: 10)
    else
      redirect_to root_path
    end
    #@user_request_page = User.paginate(page: params[:page], per_page: 10)
    #@user_request_page = User.where(:status => "waiting").page(params[:page])
  end

end
