class Item < ApplicationRecord
  before_validation {
    self.unique_name = unique_name.downcase
    self.description = description.downcase
  }

end
