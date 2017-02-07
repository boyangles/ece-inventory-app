module RequestsHelper
  def check_requests_corresponds_to_current_user
    @user = Request.find(params[:id]).user
    redirect_to(root_url) unless current_user?(@user) || current_user.privilege_admin?
  end
end
