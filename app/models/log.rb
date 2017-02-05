class Log < ApplicationRecord
  include Filterable, Subscribable

  enum request_type: {
    disbursement: 0,
    acquisition: 1,
    destruction: 2
  }
  
  scope :datetime,      -> (datetime)     { where datetime: datetime }
  scope :item_name,     -> (item_name)    { where item_name: item_name }
  scope :quantity,      -> (quantity)     { where quantity: quantity }
  scope :user,          -> (user)         { where user: user }
  scope :request_type,  -> (request_type) { where request_type: request_type }

  validates :request_type, :inclusion => { :in => REQUEST_TYPE_OPTIONS }

  # Methods:
end
