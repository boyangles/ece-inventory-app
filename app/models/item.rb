class Item < ApplicationRecord
  before_validation {
    self.unique_name = unique_name.downcase
    self.description = description.downcase
  }


  validates :unique_name, presence: true, length: { maximum: 50 },
            uniqueness: { case_sensitive: false }
  validates :quantity, presence: true
  validates :model_number, presence: true, length: { minimum: 6 }
  validates :description, presence: false, length: { maximum: 255 }
end
