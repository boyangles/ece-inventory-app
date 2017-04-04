class Stock < ApplicationRecord


  validates :serial_tag, presence: true, uniqueness: { case_sensitive: true }

  # Relation with Tags
  has_many :tags, -> { distinct },  :through => :item_tags
  has_many :item_tags

  # Relationship with CustomField
  has_many :custom_fields, -> { distinct }, :through => :stock_custom_fields
  has_many :stock_custom_fields, dependent: :destroy
  accepts_nested_attributes_for :stock_custom_fields

  # Belongs to items
  belongs_to :item

  # Relation with Logs
  has_many :logs

  before_validation {


  }

end
