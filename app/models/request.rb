class Request < ApplicationRecord
  include Filterable, Subscribable

  #relationship with items
  has_many :items,  -> {uniq}, :through => :request_items
  has_many :request_items, dependent: :destroy

  belongs_to :user

  accepts_nested_attributes_for :request_items, allow_destroy: true, :reject_if => lambda {|a| a[:item_id].blank?}

  # Default scopes
  default_scope -> { order(created_at: :desc) }

  # Data Options:
  STATUS_OPTIONS = %w(outstanding approved denied cart)

  enum request_type: {
      disbursement: 0,
      acquisition: 1,
      destruction: 2
  }

  enum status: {
    outstanding: 0,
    approved: 1,
    denied: 2,
    cart: 3
  }

  scope :user_id, -> (user_id) { where user_id: user_id }
  scope :status, -> (status) { where status: status }

  # Validations
  validates :request_type, :inclusion => { :in => REQUEST_TYPE_OPTIONS }
  validates :status, :inclusion => { :in => STATUS_OPTIONS }
  validates :user_id, presence: true

  def has_status_change_to_approved?(request_params)
    self.outstanding? && request_params[:status] == 'approved'
  end

end
