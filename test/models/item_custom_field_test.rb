require 'test_helper'

class ItemCustomFieldTest < ActiveSupport::TestCase
  def setup
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
    @item1 = Item.create!(unique_name: 'icf_item_setup_1',
                          quantity: 1000,
                          model_number: 'icf_model_1',
                          description: 'icf_description_1',
                          last_action: 0)
    @item2 = Item.create!(unique_name: 'icf_item_setup_2',
                          quantity: 1000,
                          model_number: 'icf_model_2',
                          description: 'icf_description_2',
                          last_action: 0)
  end

  test "ICF-1: Creating new item triggers creation of new ItemCustomField rows" do
    cf_count = CustomField.count

    assert_difference ['ItemCustomField.count'], cf_count do
      Item.create!(unique_name: 'item_icf_1',
                   quantity: 1000,
                   model_number: 'icf_model_1',
                   description: 'icf_description_1',
                   last_action: 0)
    end
  end

  test "ICF-2: Creating new custom field triggers creation of new ICF rows" do
    item_count = Item.count

    assert_difference ['ItemCustomField.count'], item_count do
      CustomField.create!(field_name: 'field_name_icf_2',
                          private_indicator: false,
                          field_type: 'short_text_type')
    end
  end

  test "ICF-3: Deleting item triggers deletion of ItemCustomField rows" do
    skip ("No longer deleting relations because item is not deleting")
    cf_count = CustomField.count
    assert_difference ['ItemCustomField.count'], -cf_count do
      Item.find_by(unique_name: @item1.unique_name).destroy!
    end
  end

  test "ICF-4: Deleting custom field triggers deletion of ItemCustomField rows" do
    item_count = Item.count

    assert_difference ['ItemCustomField.count'], -item_count do
      CustomField.find_by!(field_name: @cf_short_text.field_name).destroy!
    end
  end

  test "ICF-5: Testing field content gives appropriate column" do
    @icf_short_text = ItemCustomField.find_by!(item_id: @item1.id, custom_field_id: @cf_short_text.id)
    @icf_long_text = ItemCustomField.find_by!(item_id: @item1.id, custom_field_id: @cf_long_text.id)
    @icf_integer = ItemCustomField.find_by!(item_id: @item1.id, custom_field_id: @cf_integer.id)
    @icf_float = ItemCustomField.find_by!(item_id: @item1.id, custom_field_id: @cf_float.id)

    @icf_short_text.update_attributes!(short_text_content: 'test short text')
    @icf_long_text.update_attributes!(long_text_content: 'test long text')
    @icf_integer.update_attributes!(integer_content: 5)
    @icf_float.update_attributes!(float_content: 1.73)

    assert ItemCustomField.field_content(@item1.id, @cf_short_text.id) == 'test short text'
    assert ItemCustomField.field_content(@item1.id, @cf_long_text.id) == 'test long text'
    assert ItemCustomField.field_content(@item1.id, @cf_integer.id) == 5
    assert ItemCustomField.field_content(@item1.id, @cf_float.id) == 1.73
  end
end