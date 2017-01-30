require 'test_helper'

class AccountrequestsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:bernard)
    @student = users(:alex)
    @notApprovedUser = users(:adamUnapproved)
  end

  test "get account requests page as admin" do
    log_in_as(@admin)
    get accountrequests_path
    assert_response :success
  end

  test "get account requests page fails when not admin" do
    log_in_as(@student)
    get accountrequests_path
    assert_response :redirect
    assert_redirected_to root_path
  end

  test "cannot log in with email confirmed but account not verified by admin" do
    log_in_as(@notApprovedUser)
    assert_template 'new'
  end




end
