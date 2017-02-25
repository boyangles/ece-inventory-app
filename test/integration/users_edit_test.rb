require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @admin = User.create!(username: 'user_usersedittest',
                          email: 'user_usersedittest@example.com',
                          privilege: 'admin',
                          status: 'approved',
                          password: 'password',
                          password_confirmation: 'password')
  end

  test "handling unsucessful edits" do
    # Required because authorization clause in before_action for UserController
    log_in_as(@admin)
    get edit_user_path(@admin)
    assert_template 'users/edit'
    patch user_path(@admin), params: {
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
    get edit_user_path(@admin)
    log_in_as(@admin)
    assert_redirected_to edit_user_url(@admin)

    get edit_user_path(@admin)
    assert_template 'users/edit'
    username = "Bonkers Amaldoss"
    email = "bonkers@duke.edu"

    patch user_path(@admin), params: {
        user: {
            username: username,
            email: email,
            password: "password",
            password_confirmation: "password"
        }
    }

    assert_not flash.empty?
    assert_redirected_to @admin
    @admin.reload
    assert_equal username.downcase, @admin.username
    assert_equal email.downcase, @admin.email
  end
end
