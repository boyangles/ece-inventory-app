require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup parameters" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: {
                                 user: {
                                         name: "a",
                                         email: "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar",
                                         status: "me",
                                         privilege: "meh"
                                       }
                               }
    end
    assert_template 'users/new'
    assert_select 'form[action="/signup"]'
  end
end
