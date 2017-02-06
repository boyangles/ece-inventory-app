require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  def setup
    @user = users(:bernard)
    @item = items(:item1)
  end

  test "associated log and request should be destroyed when user deleted" do
    @user.save
    @item.save

    Request.create!(
      quantity: 5,
      reason: 'For test',
      status: 'outstanding',
      request_type: 'disbursement',
      user_id: @user.id,
      item_id: @item.id)
    
    Log.create!(
      quantity: 5,
      request_type: 'disbursement',
      user_id: @user.id,
      item_id: @item.id)
    
    assert_difference ['Request.count', 'Log.count'], -1 do
      @item.destroy
    end
  end
end
