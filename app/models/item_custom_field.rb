class ItemCustomField < ApplicationRecord
  belongs_to :item
  belongs_to :custom_field

  ## Validations
  validates :short_text_content, length: { maximum: 100 }, allow_nil: true
  validates :long_text_content, length: { maximum: 500 }, allow_nil: true
  validates :integer_content, numericality: { only_integer: true }, allow_nil: true
  validates :float_content, numericality: true, allow_nil: true

  ## Class Methods:
  def self.field_content(input_item_id, input_custom_field_id)
    selected_icf = ItemCustomField.find_by!(item_id: input_item_id,
                                            custom_field_id: input_custom_field_id)
    relevant_icf_column = CustomField.find_icf_field_column(input_custom_field_id)

    return selected_icf[relevant_icf_column]
  end

  def self.clear_field_content(input_item_id, input_custom_field_id)
    clear_params = {
        short_text_content: nil,
        long_text_content: nil,
        integer_content: nil,
        float_content: nil
    }

    ItemCustomField.find_by(:item_id => input_item_id, :custom_field_id => input_custom_field_id)
        .update_attributes!(clear_params)
  end

  ## Instance Methods:
end
