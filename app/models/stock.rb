class Stock < ApplicationRecord
  include Filterable


  SERIAL_TAG_LENGTH = 8

  # Relation with Tags
  has_many :tags, -> { distinct },  :through => :item_tags
  has_many :item_tags

  # Relationship with CustomField
  has_many :custom_fields, -> { distinct }, :through => :stock_custom_fields
  has_many :stock_custom_fields, dependent: :destroy
  accepts_nested_attributes_for :stock_custom_fields

  # Scope available for filterable
  scope :available, -> (available) { where available: available }


  # Belongs to items
  belongs_to :item

  # Relation with Logs
  has_many :logs

  before_create {
    generate_serial_tag!
  }

  after_create {
    create_custom_fields_for_stocks(self.id)
  }

  ## Validations
  validates :serial_tag,
            length: { :minimum => SERIAL_TAG_LENGTH, :maximum => SERIAL_TAG_LENGTH },
            uniqueness: { case_sensitive: true }, :allow_nil => true



  def generate_serial_tag!
    if !self.class.exists?(serial_tag: serial_tag) && !self.serial_tag.nil?
      return
    end

    begin
      self.serial_tag = generate_code(SERIAL_TAG_LENGTH)
    end while self.class.exists?(serial_tag: serial_tag)
  end

  def self.create_stocks!(num, item_id)
    Stock.transaction do
      for i in 1..num do
        Stock.create!(item_id: item_id, available: true)
      end
    end
  end

  ## Private variables
  private
  def generate_code(number)
    charset = Array('A'..'Z') + Array('a'..'z') + Array('0'..'9')
    Array.new(number) { charset.sample }.join
  end

  private
  def create_custom_fields_for_stocks(stock_id)
    CustomField.filter({:is_stock => true}).each do |cf|
      StockCustomField.create!(stock_id: stock_id, custom_field_id: cf.id,
                               short_text_content: nil,
                               long_text_content: nil,
                               integer_content: nil,
                               float_content: nil)
    end
  end
end
