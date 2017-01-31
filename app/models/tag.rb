class Tag < ApplicationRecord

  validates :name, presence: true, length: { maximum: 30 }, uniqueness: {case_sensitive: false}

  has_many :items, :through => :item_tags
  has_many :item_tags
  #has_and_belongs_to_many :items
  # accepts_nested_attributes_for :items

end
