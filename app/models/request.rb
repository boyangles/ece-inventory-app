class Request < ApplicationRecord
  include Filterable

  #relationship with items
  has_many :items,  -> {uniq}, :through => :request_items
  has_many :request_items, dependent: :destroy

  belongs_to :user

  # Default scopes
  default_scope -> { order(created_at: :desc) }

  # Data Options:
  STATUS_OPTIONS = %w(outstanding approved denied)

  enum status: {
    outstanding: 0,
    approved: 1,
    denied: 2,
    cart: 3
  }

  scope :user_id, -> (user_id) { where user_id: user_id }
  scope :status, -> (status) { where status: status }

  # Validations
  ## TODO: Before save, make sure all the request_items are not oversubscribed
  validates :status, :inclusion => { :in => STATUS_OPTIONS }
  validates :user_id, presence: true

  def has_status_change_to_approved?(request_params)
    self.outstanding? && request_params[:status] == 'approved'
  end
end
