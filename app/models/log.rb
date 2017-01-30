class Log < ApplicationRecord
  enum request_type: {
    disbursement: 0,
    acquisition: 1,
    destruction: 2
  }
end
