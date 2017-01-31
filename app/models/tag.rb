class Tag < ApplicationRecord

  validates :name, presence: true, length: { maximum: 30 }

  has_and_belongs_to_many :items
  # accepts_nested_attributes_for :items


end
