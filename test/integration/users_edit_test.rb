require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:bernard)
  end

  test "handling unsucessful edits" do
    # Required because authorization clause in before_action for UserController
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: {
        user: {
            username: "",
            email: "sample@invalid",
            password: "bad",
            password_confirmation: "pass"
        }
    }

    assert_template 'users/edit'
  end

  test "handling successful edits with friendly forwarding" do
    # Required because authorization clause in before_action for UserController
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)

    get edit_user_path(@user)
    assert_template 'users/edit'
    username = "Bonkers Amaldoss"
    email = "bonkers@duke.edu"

    patch user_path(@user), params: {
        user: {
            username: username,
            email: email,
            password: "password",
            password_confirmation: "password"
        }
    }

    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal username.downcase, @user.username
    assert_equal email.downcase, @user.email
  end
end
