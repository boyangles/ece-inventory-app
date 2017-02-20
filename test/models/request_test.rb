require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  def setup
    @user = users(:bernard)
    @item = items(:item1)

    @request = Request.new(
      reason: 'For test',
      status: 'outstanding',
      request_type: 'disbursement',
      user_id: @user.id)
  end

  test "should be valid" do
    assert @request.valid?
  end

  test "user id should be present" do
    @request.user_id = nil
    assert_not @request.valid?
  end
end
