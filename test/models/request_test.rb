require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  def setup
    @user = users(:bernard)
    @item = items(:item1)

    @request = Request.new(
      quantity: 5,
      reason: 'For test',
      status: 'outstanding',
      request_type: 'disbursement',
      user_id: @user.id,
      item_id: @item.id)
  end

  test "should be valid" do
    assert @request.valid?
  end

  test "user id should be present" do
    @request.user_id = nil
    assert_not @request.valid?
  end

  test "item id should be present" do
    @request.item_id = nil
    assert_not @request.valid?
  end

  test "order should be most recent first" do
    assert_equal requests(:most_recent), Request.first
  end
end
