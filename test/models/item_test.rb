require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  def setup
    @admin = users(:bernard)
    @item  = Item.create!(
        unique_name: "item23" ,
        quantity: 234,
        model_number: "15",
        description: "description",
        last_action: 0
    )
  end

  test "should be valid" do
    assert @item.valid?
  end

  test "unique_name should be present" do
    @item.unique_name = ""
    assert_not @item.valid?
  end

  test "description not required to be present" do
    @item.description = ""
    assert @item.valid?
  end

  test "model_number should be present" do
    @item.model_number= ""
    assert @item.valid?
  end

  test "quantity should be greater or equal to 0" do
    @item.quantity = -1
    assert_not @item.valid?
  end

  test "quantity should not be a string" do
    @item.quantity = "notanint"
    assert_not @item.valid?
  end

  test "quantity should not be a decimal" do
    @item.quantity = "3.5"
    assert_not @item.valid?
  end

  test "unique_name should not be that long" do
    @item.unique_name = "q" * 51
    assert_not @item.valid?
  end

  test "description should be possibly multiline" do
    @item.description = "q" * 230
    assert @item.valid?
  end

  test "unique_name should be unique" do
    duplicate_item = @item.dup
    #Testing for case insensitivity
    duplicate_item.unique_name = @item.unique_name.upcase
    @item.save
    assert_not duplicate_item.valid?
  end


end
