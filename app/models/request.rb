class Request < ApplicationRecord
  include Filterable

  enum request_type: {
    disbursement: 0,
    acquisition: 1,
    destruction: 2
  }

  enum status: {
    outstanding: 0,
    approved: 1,
    denied: 2
  }

  scope :user, -> (username) { where user: username }
  scope :status, -> (status) { where status: status }
  scope :item_id, -> (item_id) { where item_id: item_id }
end
