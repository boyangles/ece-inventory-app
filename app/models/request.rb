class Request < ApplicationRecord
  include Filterable, Subscribable

  belongs_to :item
  belongs_to :user

  # Default scopes
  default_scope -> { order(created_at: :desc) }

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

  scope :user_id, -> (user_id) { where user_id: user_id }
  scope :status, -> (status) { where status: status }
  scope :item_id, -> (item_id) { where item_id: item_id }

  # Validations
  validates :request_type, :inclusion => { :in => REQUEST_TYPE_OPTIONS }
  validates :status, :inclusion => { :in => STATUS_OPTIONS }
  validates :user_id, presence: true
  validates :item_id, presence: true

  # Methods:
  def item_relevant?(item_id)
    Item.exists?(:id => item_id)
  end

  def has_status_change_to_approved?(request_params)
    self.outstanding? && request_params[:status] == 'approved'
  end
end
