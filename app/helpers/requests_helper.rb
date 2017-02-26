module RequestsHelper
  def check_requests_corresponds_to_current_user
    @user = Request.find(params[:id]).user
    redirect_to(root_url) unless current_user?(@user) || is_manager_or_admin?
  end

  def grab_cart(usr)
  	@request = Request.where(user_id: usr.id, status: :cart).take
  end
end
