class Stock < ApplicationRecord

  SERIAL_TAG_LENGTH = 8

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

  before_create {
    generate_serial_tag!
  }

  ## Validations
  validates :serial_tag,
            length: { :minimum => SERIAL_TAG_LENGTH, :maximum => SERIAL_TAG_LENGTH },
            uniqueness: { case_sensitive: true }, :allow_nil => true

  def generate_serial_tag!
    begin
      self.serial_tag = generate_code(SERIAL_TAG_LENGTH)
    end while self.class.exists?(serial_tag: serial_tag)
  end

  ## Private variables
  private
  def generate_code(number)
    charset = Array('A'..'Z') + Array('a'..'z') + Array('0'..'9')
    Array.new(number) { charset.sample }.join
  end

end
