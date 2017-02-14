class RequestItem < ApplicationRecord
  include Subscribable

  belongs_to :request
  belongs_to :item

  enum request_type: {
      disbursement: 0,
      acquisition: 1,
      destruction: 2
  }

  # Validations
  validates :request_type, :inclusion => { :in => REQUEST_TYPE_OPTIONS }
end
