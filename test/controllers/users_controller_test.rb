require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(username: 'user_userscontrollertest',
                          email: 'user_userscontrollertest@example.com',
                          privilege: 'admin',
                          status: 'approved',
                          password: 'password',
                          password_confirmation: 'password')
    @user2 = User.create!(username: 'user2_userscontrollertest',
                          email: 'user2_userscontrollertest@example.com',
                          privilege: 'student',
                          status: 'approved',
                          password: 'password',
                          password_confirmation: 'password')
    @admin = User.create!(username: 'admin_userscontrollertest',
                          email: 'admin_userscontrollertest@example.com',
                          privilege: 'admin',
                          status: 'approved',
                          password: 'password',
                          password_confirmation: 'password')
    @student = User.create!(username: 'student_userscontrollertest',
                              email: 'student_userscontrollertest@example.com',
                              privilege: 'student',
                              status: 'approved',
                              password: 'password',
                              password_confirmation: 'password')
  end

  test "redirect to login page with index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "redirect to login page with edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "redirect to login page with update when not logged in" do
    patch user_path(@user), params: {
        user: {
            username: @user.username,
            email: @user.email
        }
    }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "redirect to homepage with edit when logged in as different user" do
    log_in_as(@user2)
    get edit_user_path(@user)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "redirect to homepage with update when logged in as different user" do
    log_in_as(@user2)
    patch user_path(@user), params: {
        user: {
            username: @user.username,
            email: @user.email
        }
    }

    assert flash.empty?
    assert_redirected_to root_url
  end

  # Security Test:
  test "privilege attribute should not be editable via web" do
    log_in_as(@user2)
    assert_not @user2.privilege_admin?
    patch user_path(@user2), params: {
        user: {
            password: "password",
            password_confirmation: "password",
            privilege: "admin"
        }
    }

    assert_not @user2.privilege_admin?
  end

  test "redirect to login screen when destroying and not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  test "should redirect to root url when destroying and non-admin" do
    log_in_as(@user2)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end

  test "create local account through admin user" do
    log_in_as(@admin)
    get new_user_path
    assert_difference 'User.count' do
      post users_path, params: {
          user: {
              username: "cotton eyed joe",
              email: "cottonjoe@email.com",
              password: "password",
              password_confirmation: "password"
          }
      }
    end

    assert_redirected_to users_path

    @new_user = User.find_by(:email => "cottonjoe@email.com")
    assert Request.where(:user_id => @new_user.id).where(:status => :cart).exists?
  end

  test "cannot create new user through non admin account" do
    log_in_as(@student)
    get new_user_path
    assert_no_difference 'User.count' do
      post users_path, params: {
          user: {
              username: "cotton eyed joe",
              email: "cottonjoe@email.com",
              password: "password",
              password_confirmation: "password"
          }
      }
    end
    assert_redirected_to root_path
  end
end
