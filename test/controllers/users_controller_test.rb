require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:bernard)
  end
  
  test "should get new" do
    get signup_url
    assert_response :success
  end

  test "redirect to login page with edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "redirect update when not logged in" do
    patch user_path(@user), params: {
      user: {
        username: @user.username,
        email: @user.email
      }
    }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
end
