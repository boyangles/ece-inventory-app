class Log < ApplicationRecord
  include Filterable, Subscribable

  belongs_to :item
  belongs_to :user

  enum request_type: {
    disbursement: 0,
    acquisition: 1,
    destruction: 2
  }
  
  scope :item_id,       -> (item_id)      { where item_id: item_id }
  scope :quantity,      -> (quantity)     { where quantity: quantity }
  scope :user_id,       -> (user_id)      { where user_id: user_id }
  scope :request_type,  -> (request_type) { where request_type: request_type }

  validates :request_type, :inclusion => { :in => REQUEST_TYPE_OPTIONS }

  # Methods:
end
