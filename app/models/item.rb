class Item < ApplicationRecord
  validates :unique_name, presence: true, length: { maximum: 50 },
            uniqueness: { case_sensitive: false }
  validates :quantity, presence: true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :description, length: { maximum: 255 }

  # Relation with Tags
  has_many :tags, -> { uniq },  :through => :item_tags
  has_many :item_tags

  # Relation with Requests
  has_many :requests, dependent: :destroy

  # Relation with Logs
  has_many :logs, dependent: :destroy

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

  def self.filter_by_model_search(search_input)
    if search_input.to_s.strip.empty?
      all
    else
      where(:model_number => search_input.strip)
    end
  end

  def update_by_request(request) 
    case request.request_type.to_sym
    when :disbursement
      self[:quantity] = self[:quantity] - request[:quantity]
    when :acquisition
      self[:quantity] = self[:quantity] + request[:quantity]
    when :destruction
      self[:quantity] = self[:quantity] - request[:quantity]
    else
      self[:quantity]
    end
  end
end
