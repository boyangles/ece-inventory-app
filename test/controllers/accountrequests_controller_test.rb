require 'test_helper'

class AccountrequestsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:bernard)
    @user2 = users(:alex)
    @nonadmin = users(:adamUnapproved)
    @user4 = users(:joeUnapproved)
  end

  test "get account requests page as admin" do
    log_in_as(@admin)
    get accountrequests_path
    assert_response :success
  end

  test "get account requests page fails when not admin" do
    log_in_as(@nonadmin)
    get accountrequests_path
    assert_response :redirect
    assert_redirected_to root_path
  end




end
