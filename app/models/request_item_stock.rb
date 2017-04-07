class RequestItemStock < ApplicationRecord
  include Filterable

  RQ_ITEM_STOCK_STATUS_OPTIONS = %w(disburse loan)

  belongs_to :request_item
  belongs_to :stock

  enum status: {
      disburse: 0,
      loan: 1
  }

  scope :request_item_id, -> (request_item_id) {  where request_item_id: request_item_id }
  scope :stock_id, -> (stock_id) { where stock_id: stock_id }
  scope :item_id, -> (item_id) { joins(:stock).where(stocks: { item_id: item_id }) }
  scope :available, -> (available) { joins(:stock).where(stocks: { available: available }) }
  scope :unavailable, -> (unavailable) { joins(:stock).where(stocks: { available: !unavailable }) }


  validates :status, :inclusion => { :in => RQ_ITEM_STOCK_STATUS_OPTIONS }

end
