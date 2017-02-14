require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup parameters" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: {
          user: {
              username: "a",
              email: "user@invalid",
              password: "foo",
              password_confirmation: "bar"
          }
      }
    end
    
    assert_template 'users/new'
    assert_select 'form[action="/signup"]'
  end

  # Need to test logging in with confirmed credentials
  test "valid signup and log in after email confirmed" do

  end

  #not sure this is a great test now
  test "valid signup and redirection" do
    get signup_path
    post users_path, params: {
        user: {
            username: "username",
            email: "user@duke.edu",
            password: "password1",
            password_confirmation: "password1",
        }
    }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_template 'user_mailer/welcome_email'
  end
end
