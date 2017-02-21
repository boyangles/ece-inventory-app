class CustomField < ApplicationRecord

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

  ## Validations
  validates :field_name, :exclusion => { :in => INTRINSIC_FIELD_NAMES },
            presence: true, uniqueness: true
  validates :private_indicator, :inclusion => { in: [ true, false ] }
  validates :field_type, :inclusion => { :in => FIELD_TYPE_OPTIONS }
end
