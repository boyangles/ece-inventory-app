require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @user = users(:bernard)
    @admin = users(:bernard)
    @non_admin = users(:alex)

    @request_user = Request.new(
        reason: 'For test',
        status: 'cart',
        request_type: 'disbursement',
        user_id: @user.id)
    @request_user.save!

    @request_admin = Request.new(
        reason: 'For test',
        status: 'cart',
        request_type: 'disbursement',
        user_id: @admin.id)
    @request_admin.save!

    @request_nonadmin = Request.new(
        reason: 'For test',
        status: 'cart',
        request_type: 'disbursement',
        user_id: @non_admin.id)
    @request_nonadmin.save!
  end

  # Catches the bug where the flash persists for more than a single page
  test "login with incorrect information" do
    get login_path # Visit the login path
    assert_template 'sessions/new' #Verifies that the new session form renders
    post login_path, params: { session: { username: "", password: "" } } # Invalid
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  # Tests valid login:
  # 1. Visit login path
  # 2. HTTP post valid information to session path
  # 3. verify that login link disappears
  # 4. Verify that a logout link appears
  # 5. Verify that a profile link appears
  test "login with correct information and then logout correctly" do
    # Step 1
    get login_path

    # Step 2
    post login_path, params: {
        session: {
            username: @user.username,
            password: 'password'
        }
    }

    assert is_logged_in?

    # Verify that redirect to user page
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'

    # Step 3
    assert_select "a[href=?]", login_path, count: 0

    # Step 4
    assert_select "a[href=?]", logout_path

    # Step 5
    assert_select "a[href=?]", user_path(@user)

    # Logout time:
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  # Logged in users should never be able to see the login page
  test "viewing login page as an admin redirects to root path" do
    log_in_as(@admin)
    assert is_logged_in?
    get login_path
    assert_redirected_to root_path
  end
  test "viewing login page as an non-admin redirects to root path" do
    log_in_as(@non_admin)
    assert is_logged_in?

    get login_path

    assert_redirected_to root_path
  end

  test "Create local account as admin, log out, then log in with local" do
    log_in_as(@admin)
    get new_user_path

    post users_path, params: {
        user: {
            username: "cotton eyed joe",
            email: "cottonjoe@email.com",
            password: "password",
            password_confirmation: "password"
        }
    }
    @created_user = User.find_by(:username => "cotton eyed joe")

    @cart = Request.new(
      reason: 'For test',
      status: 'cart',
      request_type: 'disbursement',
      user_id: @created_user.id)
    @cart.save!

    delete logout_path
    assert_not is_logged_in?
    log_in_as(@user)
    assert_redirected_to user_path(@user)
  end
end