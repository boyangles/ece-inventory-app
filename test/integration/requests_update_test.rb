require 'test_helper'

class RequestsUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @item1 = items(:item1)
    @item2 = items(:item2)
    @item3 = items(:item3)
    @item4 = items(:item4)
    @item5 = items(:item5)

    @user = users(:bernard)
    @user2 = users(:alex)
    @admin = users(:admin)
  end
end