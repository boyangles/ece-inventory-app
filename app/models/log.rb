class Log < ApplicationRecord
  include Filterable

  REQUEST_TYPE_OPTIONS = %w(disbursement acquisition destruction)

  enum request_type: {
    disbursement: 0,
    acquisition: 1,
    destruction: 2
  }
  
  scope :datetime,      -> (datetime)     { where datetime: datetime }
  scope :item_id,       -> (item_id)      { where item_id: item_id }
  scope :quantity,      -> (quantity)     { where quantity: quantity }
  scope :user_id,       -> (user_id)      { where user_id: user_id }
  scope :request_type,  -> (request_type) { where request_type: request_type }

  validates :request_type, :inclusion => { :in => REQUEST_TYPE_OPTIONS }
end
