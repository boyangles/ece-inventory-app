require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:bernard)
    @non_admin = users(:alex)

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

  test "index, pagination, and deletion as administrator" do
    log_in_as(@admin)

    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page = User.paginate(page: 1, per_page: 1)
    
    first_page.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.username
      unless user.privilege_admin?
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end

    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "viewing index as a non-admin redirects to root path" do
    log_in_as(@non_admin)
    get users_path
    
    assert_redirected_to root_path
  end
end
