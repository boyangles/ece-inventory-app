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
end
