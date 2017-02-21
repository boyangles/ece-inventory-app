class ItemCustomField < ApplicationRecord
  belongs_to :item
  belongs_to :custom_field

  ## Validations
  validates :short_text_content, length: { maximum: 100 }
  validates :long_text_content, length: { maximum: 500 }
  validates :integer_content, numericality: { only_integer: true }
  validates :float_content, numericality: true
end
