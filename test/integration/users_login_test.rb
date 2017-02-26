require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @manager = User.create!(username: 'user_userlogintest',
                          email: 'user_userlogintest@example.com',
                          privilege: 'manager',
                          status: 'approved',
                          password: 'password',
                          password_confirmation: 'password')
    @admin = User.create!(username: 'admin_userlogintest',
                          email: 'admin_userlogintest@example.com',
                          privilege: 'admin',
                          status: 'approved',
                          password: 'password',
                          password_confirmation: 'password')
    @non_admin = User.create!(username: 'nonadmin_userlogintest',
                          email: 'nonadmin_userlogintest@example.com',
                          privilege: 'student',
                          status: 'approved',
                          password: 'password',
                          password_confirmation: 'password')
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
            username: @admin.username,
            password: 'password'
        }
    }

    assert is_logged_in?

    # Verify that redirect to user page
    assert_redirected_to @admin
    follow_redirect!
    assert_template 'users/show'

    # Step 3
    assert_select "a[href=?]", login_path, count: 0

    # Step 4
    assert_select "a[href=?]", logout_path

    # Step 5
    assert_select "a[href=?]", user_path(@admin)

    # Logout time:
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@admin), count: 0
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

    # Cart automatically created when user is created
    assert Request.exists?(:user_id => @created_user.id)

    delete logout_path
    assert_not is_logged_in?
    log_in_as(@created_user)
    assert_redirected_to user_path(@created_user)
  end
end