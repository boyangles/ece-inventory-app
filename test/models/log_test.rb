require 'test_helper'

class LogTest < ActiveSupport::TestCase
  def setup
    @user = users(:bernard)
    @item = items(:item1)

    @log = Log.new(
      datetime: Time.now,
      quantity: 5,
      request_type: 'disbursement',
      user_id: @user.id,
      item_id: @item.id)
  end

  test "should be valid" do
    assert @log.valid?
  end

  test "user id should be present" do
    @log.user_id = nil
    assert_not @log.valid?
  end

  test "item id should be present" do
    @log.item_id = nil
    assert_not @log.valid?
  end
end
