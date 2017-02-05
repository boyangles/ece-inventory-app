require 'test_helper'

class ItemsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @item = items(:item1)
    @item2 = users(:item2)
  end

  # test "create new item works with admin" do
  #   log_in_as(@admin)
  #
  #   assert_redirected_to new_item_url
  # end
  #
  # test "redirect to login page with index when not logged in" do
  #   get users_path
  #   assert_redirected_to login_url
  # end
  #
  # test "redirect to login page with edit when not logged in" do
  #   get edit_user_path(@user)
  #   assert_not flash.empty?
  #   assert_redirected_to login_url
  # end
  #
  # test "redirect to login page with update when not logged in" do
  #   patch user_path(@user), params: {
  #       user: {
  #           username: @user.username,
  #           email: @user.email
  #       }
  #   }
  #   assert_not flash.empty?
  #   assert_redirected_to login_url
  # end
  #
  # test "redirect to homepage with edit when logged in as different user" do
  #   log_in_as(@user2)
  #   get edit_user_path(@user)
  #   assert flash.empty?
  #   assert_redirected_to root_url
  # end
  #
  # test "redirect to homepage with update when logged in as different user" do
  #   log_in_as(@user2)
  #   patch user_path(@user), params: {
  #       user: {
  #           username: @user.username,
  #           email: @user.email
  #       }
  #   }
  #
  #   assert flash.empty?
  #   assert_redirected_to root_url
  # end
  #
  # # Security Test:
  # test "privilege attribute should not be editable via web" do
  #   log_in_as(@user2)
  #   assert_not @user2.privilege_admin?
  #   patch user_path(@user2), params: {
  #       user: {
  #           password: "password",
  #           password_confirmation: "password",
  #           privilege: 2
  #       }
  #   }
  #
  #   assert_not @user2.privilege_admin?
  # end
  #
  # test "redirect to login screen when destroying and not logged in" do
  #   assert_no_difference 'User.count' do
  #     delete user_path(@user)
  #   end
  #   assert_redirected_to login_url
  # end
  #
  # test "should redirect to root url when destroying and non-admin" do
  #   log_in_as(@user2)
  #   assert_no_difference 'User.count' do
  #     delete user_path(@user)
  #   end
  #   assert_redirected_to root_url
  # end
end
