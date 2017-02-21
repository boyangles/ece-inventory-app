require 'test_helper'

class CustomFieldTest < ActiveSupport::TestCase
  def setup
    @cf1 = CustomField.new(field_name: 'price',
                           private_indicator: false,
                           field_type: 'long_text_type')
  end

  test "CF-1: Adding two CustomFields with the same field_name should fail" do
    @cf2 = @cf1.dup

    @cf1.save!
    assert_not @cf2.valid?
  end

  test "CF-2: field_name must be present for CustomFields" do
    assert @cf1.valid?

    @cf1.field_name = ''
    assert_not @cf1.valid?
  end

  test "CF-3: private_indicator should only be true or false" do
    assert @cf1.valid?

    @cf1.private_indicator = nil
    assert_not @cf1.valid?
  end

  test "CF-4: field_type must be part of defined enums for CustomFields" do
    assert @cf1.valid?

    assert_raise ArgumentError do
      @cf1.field_type = 'incorrect_field_type'
    end
  end

  test "CF-5: Admins cannot create names from CustomFields that are intrinsic" do
    assert @cf1.valid?

    CustomField::INTRINSIC_FIELD_NAMES.each do |intrinsic_field|
      @cf1.field_name = intrinsic_field
      assert_not @cf1.valid?
    end
  end
end