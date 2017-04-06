class RequestItemStock < ApplicationRecord

  RQ_ITEM_STOCK_STATUS_OPTIONS = %w(disburse loan)

  enum status: {
      disburse: 0,
      loan: 1
  }

  validates :status, :inclusion => { :in => RQ_ITEM_STOCK_STATUS_OPTIONS }

end
