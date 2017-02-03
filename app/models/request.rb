class Request < ApplicationRecord
  include Filterable

  # Data Options:
  REQUEST_TYPE_OPTIONS = %w(disbursement acquisition destruction)
  STATUS_OPTIONS = %w(outstanding approved denied)

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
  scope :item_name, -> (item_name) { where item_name: item_name }

  # Validations
  validates :request_type, :inclusion => { :in => REQUEST_TYPE_OPTIONS }
  validates :status, :inclusion => { :in => STATUS_OPTIONS }
end
