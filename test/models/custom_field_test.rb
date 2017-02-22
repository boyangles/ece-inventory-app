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

  test "CF-6: Add CustomField with all the correct parameters succeeds" do
    @cf_sample = CustomField.new(field_name: 'location',
                                 private_indicator: false,
                                 field_type: 'short_text_type')
    assert @cf_sample.valid?
  end

  test "CF-7: Test removing fields via destroy" do
    @cf_location = CustomField.create!(field_name: 'location',
                                       private_indicator: false,
                                       field_type: 'short_text_type')
    @cf_restock_info = CustomField.create!(field_name: 'restock_info',
                                           private_indicator: true,
                                           field_type: 'long_text_type')

    assert_difference ['CustomField.count'], -2 do
      @cf_location.destroy!
      @cf_restock_info.destroy!
    end
  end

  test "CF-8: Test Finding appropriate column for ItemCustomField" do
    @cf_short_text = CustomField.create!(field_name: 'short_text_field',
                                         private_indicator: false,
                                         field_type: 'short_text_type')
    @cf_long_text = CustomField.create!(field_name: 'long_text_field',
                                        private_indicator: false,
                                        field_type: 'long_text_type')
    @cf_integer = CustomField.create!(field_name: 'integer_field',
                                      private_indicator: false,
                                      field_type: 'integer_type')
    @cf_float = CustomField.create!(field_name: 'float_field',
                                    private_indicator: false,
                                    field_type: 'float_type')

    assert CustomField.find_icf_field_column(@cf_short_text.id) == :short_text_content
    assert CustomField.find_icf_field_column(@cf_long_text.id) == :long_text_content
    assert CustomField.find_icf_field_column(@cf_integer.id) == :integer_content
    assert CustomField.find_icf_field_column(@cf_float.id) == :float_content
  end
end