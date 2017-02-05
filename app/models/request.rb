class Request < ApplicationRecord
  include Filterable, Subscribable

  # Data Options:
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

  # Methods:
  def item_relevant?(item_name)
    Item.exists?(:unique_name => item_name)
  end

  def has_status_change_to_approved?(request_params)
    self.outstanding? && request_params[:status] == 'approved'
  end
end
