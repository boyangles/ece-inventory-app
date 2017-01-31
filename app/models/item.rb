class Item < ApplicationRecord

  validates :unique_name, presence: true, length: { maximum: 50 },
            uniqueness: { case_sensitive: false }
  validates :quantity, presence: true
  validates :model_number, presence: true
  validates :description, length: { maximum: 255 }


  has_many :tags, :through => :item_tags
  has_many :item_tags
  #has_and_belongs_to_many :tags
  # accepts_nested_attributes_for :tags

end
