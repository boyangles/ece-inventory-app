class Item < ApplicationRecord

  validates :unique_name, presence: true, length: { maximum: 50 },
            uniqueness: { case_sensitive: false }
  validates :quantity, presence: true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :model_number, presence: true
  validates :description, length: { maximum: 255 }


  has_many :tags, -> { distinct },  :through => :item_tags
  has_many :item_tags

  def self.tagged_with_all(tag_filters)
    if(tag_filters.length == 0)
      all
    else
      joins(:tags).where('tags.name IN (?)', tag_filters).group('items.id').having('count(*)=?', tag_filters.count)
    end
  end

  def self.tagged_with_none(tag_filters)
    if(tag_filters.length == 0)
      all
    else
      where("items.id IN (?)", select('items.id') - joins(:tags).where('tags.name IN (?)', tag_filters).distinct.select('items.id'))
    end
  end

  def self.filter_by_search(search_input)
    where("unique_name ILIKE ?", "%#{search_input}%") 
  end
end
