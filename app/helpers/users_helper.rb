module UsersHelper

  def gravatar_for(user, options = {size: 80})
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.username, class: "gravatar")
  end

  # Checks that the current user is an administrator
  def check_admin_user
    redirect_to(root_url) unless current_user && current_user.privilege == 'admin'
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
    redirect_to(root_url) unless current_user && current_user.status == 'approved'
  end
end
