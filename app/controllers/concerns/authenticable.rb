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

  def auth_by_admin_privilege!
    render json: { errors: 'No sufficient privileges' },
                  status: :unauthorized unless current_user_by_auth.privilege_admin?
  end

  def auth_by_same_user_or_admin!(user_id)
    user_to_show = User.find(user_id)
    curr_user = current_user_by_auth

    render json: { errors: 'No sufficient privileges' },
                  status: :unauthorized unless
        curr_user.privilege_admin? || curr_user.id == user_to_show.id
  end
end