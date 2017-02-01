class Item < ApplicationRecord

  validates :unique_name, presence: true, length: { maximum: 50 },
            uniqueness: { case_sensitive: false }
  validates :quantity, presence: true, :numericality => {:only_integer => true}
  validates :model_number, presence: true
  validates :description, length: { maximum: 255 }
end
