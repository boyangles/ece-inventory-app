module Authenticable
  # Devise method overwrites
  def current_user_by_auth
    @current_user_by_auth ||= User.find_by(auth_token: request.headers['Authorization'])
  end
end