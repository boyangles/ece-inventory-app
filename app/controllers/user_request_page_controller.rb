class UserRequestPageController < ApplicationController

  def index
    @user_request_page = User.where(:status => "waiting").paginate(page: params[:page], per_page: 10)
    #@user_request_page = User.paginate(page: params[:page], per_page: 10)
    #@user_request_page = User.where(:status => "waiting").page(params[:page])
  end

end
