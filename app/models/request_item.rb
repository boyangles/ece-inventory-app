class RequestItem < ApplicationRecord
  include Filterable

  belongs_to :request
  belongs_to :item

  # Scopes for filtering
  scope :request_id, -> (request_id) { where request_id: request_id }
  scope :item_id, -> (item_id) { where item_id: item_id }
  scope :quantity, -> (quantity) { where quantity: quantity }
end
