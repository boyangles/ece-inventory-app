require 'test_helper'

class RequestsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @item1 = items(:item1)
    @item2 = items(:item2)
    @item3 = items(:item3)
    @item4 = items(:item4)
    @item5 = items(:item5)

    @admin = users(:bernard)
    @student1 = users(:alex)
    @admin = users(:admin)
  end

  test "redirect to login page when not logged in" do
    get users_path
    assert_redirected_to login_url

    get user_path(@admin)
    assert_redirected_to login_url

    get edit_user_path(@admin)
    assert_redirected_to login_url
  end

  test "redirect to homepage when logged in as different user and not admin" do
    log_in_as(@student1)

    Request.create!(
        reason: 'For test',
        status: 'outstanding',
        request_type: 'disbursement',
        user_id: @admin.id)

    @req = Request.find_by(:user_id => @admin.id)

    get edit_request_path(@req)
    assert flash.empty?
    assert_redirected_to root_url

    patch request_path(@req), params: {
        id: @req.id,
        request: {
            reason: 'For fun!',
            status: 'outstanding',
            request_type: 'disbursement'
        }
    }
    assert flash.empty?
    assert_redirected_to root_url

    delete request_path(@req)
    assert flash.empty?
    assert_redirected_to root_url

    get request_path(@req)
    assert_redirected_to root_url
  end
end