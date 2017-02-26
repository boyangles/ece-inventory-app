module Renderable
  def render_simple_user(user, status_number)
    render :json => user.instance_eval {
        |u| {
          :id => u.id,
          :email => u.email,
          :status => u.status,
          :permission => u.privilege
      }
    }, status: status_number
  end

  def render_user_with_auth_token(user, status_number)
    render :json => user.instance_eval {
      |u| {
          :id => u.id,
          :email => u.email,
          :permission => u.privilege,
          :authorization => u.auth_token
      }
    }, status: status_number
  end

  def update_user_and_render(user, update_params)
    if user.update(update_params)
      render_simple_user(user, 200)
    else
      render_client_error(user.errors, 422)
    end
  end
end