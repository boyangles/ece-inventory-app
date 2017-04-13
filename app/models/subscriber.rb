class Subscriber < ApplicationRecord
  include Filterable

  belongs_to :user

  # Scopes for filtering
  scope :status, -> (status) { joins(:user).where(users: { status: status }) }
end
