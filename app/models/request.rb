class Request < ApplicationRecord
  include Filterable

  scope :user, -> (username) { where user: username }
end
