class Log < ApplicationRecord
  include Filterable

  enum request_type: {
    disbursement: 0,
    acquisition: 1,
    destruction: 2
  }
  
  scope :quantity, -> (quantity) {where quantity: quantity }
end
