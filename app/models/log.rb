class Log < ApplicationRecord
  include Filterable

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

end
