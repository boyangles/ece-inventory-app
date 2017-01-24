require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:bernard)
  end

  test "handling unsucessful edits" do
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

  test "handling successful edits" do
    get edit_user_path(@user)
    assert_template 'users/edit'
    username = "Bonkers Amaldoss"
    email = "bonkers@duke.edu"
    
    patch user_path(@user), params: {
      user: {
        username: username,
        email: email,
        password: "",
        password_confirmation: ""
      }
    }

    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal username.downcase, @user.username
    assert_equal email.downcase, @user.email
  end
end
