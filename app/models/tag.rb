class Tag < ApplicationRecord

  validates :name, presence: true, length: { maximum: 30 }, uniqueness: {case_sensitive: false}

  has_many :items,  -> { distinct }, :through => :item_tags
  has_many :item_tags
end
