class RequestItemComment < ApplicationRecord
  include Filterable

  belongs_to :request_item
  belongs_to :user

  validates :comment, presence: true, length: { maximum: 600, minimum: 1 }
end