require 'test_helper'

class UserRequestPageControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:bernard)
    @user2 = users(:alex)
    @user3 = users(:adamUnapproved)
    @user4 = users(:joeUnapproved)
  end

  test "get user requests page" do
    get userrequests_path
    assert_response :success
  end




end
