require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = User.create!(username: 'user_userscontrollertest',
                          email: 'user_userscontrollertest@example.com',
                          privilege: 'admin',
                          status: 'approved',
                          password: 'password',
                          password_confirmation: 'password')
    @student1 = User.create!(username: 'user2_userscontrollertest',
                             email: 'user2_userscontrollertest@example.com',
                             privilege: 'student',
                             status: 'approved',
                             password: 'password',
                             password_confirmation: 'password')
    @manager = User.create!(username: 'managerUserContorllerTest',
                             email: 'manager_userscontrollertest@example.com',
                             privilege: 'manager',
                             status: 'approved',
                             password: 'password',
                             password_confirmation: 'password')
  end

  test "redirect to login page with index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "redirect to login page with edit when not logged in" do
    get edit_user_path(@admin)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "redirect to login page with update when not logged in" do
    patch user_path(@admin), params: {
        admin: {
            username: @admin.username,
            email: @admin.email
        }
    }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "redirect to homepage with edit when logged in as different user" do
    log_in_as(@student1)
    get edit_user_path(@admin)
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "redirect to homepage with update when logged in as different user" do
    log_in_as(@student1)
    patch user_path(@admin), params: {
        admin: {
            username: @admin.username,
            email: @admin.email
        }
    }

    assert flash.empty?
    assert_redirected_to root_url
  end

  # Security Test:
  test "privilege attribute should not be editable via web" do
    log_in_as(@student1)
    assert_not @student1.privilege_admin?
    patch user_path(@student1), params: {
        admin: {
            password: "password",
            password_confirmation: "password",
            privilege: "admin"
        }
    }

    assert_not @student1.privilege_admin?
  end

  test "redirect to login screen when destroying and not logged in" do
    assert_no_difference 'User.count' do
      delete user_path(@admin)
    end
    assert_redirected_to login_url
  end

  test "should redirect to root url when destroying and non-admin" do
    log_in_as(@student1)
    assert_no_difference 'User.count' do
      delete user_path(@admin)
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

  test "cannot create new user through student account" do
    log_in_as(@student1)
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

  test "cannot create new user through manager account" do
    log_in_as(@manager)
    get new_user_path
    assert_no_difference 'User.count' do
      post users_path, params: {
          user: {
              username: "cotton eyed joe2",
              email: "cottonjoe2@email.com",
              password: "password",
              password_confirmation: "password"
          }
      }
    end
    assert_redirected_to root_path
  end
end
