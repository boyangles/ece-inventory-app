module SessionsHelper

  # Logs in user
  def log_in(user)
    session[:user_id] = user.id
  end

  # Logs out the current user
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  # Returns true if given user is current user
  def current_user?(user)
    user == current_user
  end

  # Returns the current logged-in user, and nil if no logged-in user
  def current_user
    # find_by only executes when current user hasn't been assigned yet
    @current_user ||= User.find_by(id: session[:user_id])
  end

  # Returns true if the user is logged in, false otherwise
  # Useful for code to show one set of links if the user is logged in and another set of links otherwise, e.g.
  #
  # <% if logged_in? %>
  #   # Links for logged in users
  # <% else %>
  #   # Links for non-logged in users
  # <% end %>
  #
  def logged_in?
    !current_user.nil?
  end

  # Redirect to stored location/default
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Store URL attempting to be accessed
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
  
  # Checks that the current user is an administrator
  def check_admin_user
    redirect_to(root_url) unless current_user && current_user.privilege_admin?
  end

  # Confirms logged-in user
  def check_logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Login is required to access page."
      redirect_to login_url and return
    end
  end

  # Confirms correct user, otherwise redirect to homepage
  def check_current_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  # Confirms status is approved
  def check_approved_user
    redirect_to(root_url) unless current_user && current_user.status_approved?
  end

  def activate_user(user)
    user.status = "approved"
    user.save!(:validate => false)
  end
end
