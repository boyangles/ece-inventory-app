class CustomField < ApplicationRecord
  include Filterable

  has_many :items, -> { uniq }, :through => :item_custom_fields
  has_many :item_custom_fields, dependent: :destroy

  # Data Options;
  FIELD_TYPE_OPTIONS = %w(short_text_type long_text_type integer_type float_type)
  INTRINSIC_FIELD_NAMES = %w(name description)

  enum field_type: {
    short_text_type: 0,
    long_text_type: 1,
    integer_type: 2,
    float_type: 3
  }

  # Filterable params:
  scope :field_name, -> (field_name) { where field_name: field_name }
  scope :private_indicator, -> (private_indicator) { where private_indicator: private_indicator }
  scope :field_type, -> (field_type) { where field_type: field_type }

  ## Validations
  validates :field_name, :exclusion => { :in => INTRINSIC_FIELD_NAMES },
            presence: true, uniqueness: true
  validates :private_indicator, :inclusion => { in: [ true, false ] }
  validates :field_type, :inclusion => { :in => FIELD_TYPE_OPTIONS }

  after_update :clear_associated_field_entries, if: :field_type_changed?
  after_create {
    create_items_for_custom_fields(self.id)
  }

  ## Class Methods:
  def self.find_icf_field_column(input_custom_field_id)
    selected_field_type = CustomField.find(input_custom_field_id).field_type

    case selected_field_type
      when 'short_text_type'
        return :short_text_content
      when 'long_text_type'
        return :long_text_content
      when 'integer_type'
        return :integer_content
      when 'float_type'
        return :float_content
      else
        return nil
    end
  end

  def self.pretty_field_type(input_custom_field_id)
    selected_field_type = CustomField.find(input_custom_field_id).field_type

    case selected_field_type
      when 'short_text_type'
        return "Short Text"
      when 'long_text_type'
        return "Long Text"
      when 'integer_type'
        return "Integer"
      when 'float_type'
        return "Decimal"
      else
        return nil
    end
  end

  ## Instance Methods:
  def clear_associated_field_entries
    icfs = self.item_custom_fields
    clear_params = {
        short_text_content: nil,
        long_text_content: nil,
        integer_content: nil,
        float_content: nil
    }

    icfs.each do |icf|
      icf.update_attributes!(clear_params)
    end
  end

  private
  def create_items_for_custom_fields(custom_field_id)
    Item.all.each do |item|
      ItemCustomField.create!(item_id: item.id, custom_field_id: custom_field_id,
                              short_text_content: nil,
                              long_text_content: nil,
                              integer_content: nil,
                              float_content: nil)
    end
  end
end
