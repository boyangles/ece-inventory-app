module Authenticable
  # Devise method overwrites
  def current_user_by_auth
    @current_user_by_auth ||= User.find_by(auth_token: request.headers['Authorization'])
  end

  def user_signed_in?
    current_user_by_auth.present?
  end

  def authenticate_with_token!
    render json: { errors: 'Not authenticated' },
                  status: :unauthorized unless user_signed_in?
  end

  def auth_by_approved_status!
    curr_user = current_user_by_auth

    render json: { errors: 'Account is not approved for this action' },
           status: :unauthorized unless curr_user && curr_user.status_approved?
  end

  def auth_by_admin_privilege!
    render json: { errors: 'No sufficient privileges' },
                  status: :unauthorized unless current_user_by_auth.privilege_admin?
  end

  def auth_by_manager_privilege!
    render json: { errors: 'No sufficient privileges' },
           status: :unauthorized unless current_user_by_auth.privilege_admin? || current_user_by_auth.privilege_manager?
  end

  def auth_by_same_user_or_manager!(user_id)
    user_to_show = User.find(user_id)
    curr_user = current_user_by_auth

    render json: { errors: 'No sufficient privileges' },
                  status: :unauthorized unless
        curr_user &&
            (curr_user.privilege_admin? ||
                curr_user.privilege_manager? ||
                curr_user.id == user_to_show.id)
  end

  def auth_by_same_user!(user_id)
    user = User.find(user_id)
    curr_user = current_user_by_auth

    render json: { errors: 'No sufficient privileges' },
           status: :unauthorized unless curr_user && curr_user.id == user.id
  end

  def auth_by_not_same_user!(user_id)
    user = User.find(user_id)
    curr_user = current_user_by_auth

    render json: { errors: 'Action cannot be done on yourself' },
           status: :unauthorized unless curr_user && curr_user.id != user.id
  end

  def auth_by_check_requests_corresponds_to_current_user!
    @user = Request.find(params[:id]).user
    render json: {errors: 'No sufficient privileges' },
           status: :unauthorized unless current_user_by_auth.id == @user.id || current_user_by_auth.privilege_admin? || current_user_by_auth.privilege_manager?
  end
end