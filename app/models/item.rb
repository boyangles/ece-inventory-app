class Item < ApplicationRecord
  validates :unique_name, presence: true, length: { maximum: 50 },
            uniqueness: { case_sensitive: false }
  validates :quantity, presence: true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :description, length: { maximum: 255 }

  # Relation with Tags
  has_many :tags, -> { distinct },  :through => :item_tags
  has_many :item_tags

  # Relation with Requests
  has_many :requests, -> { uniq },  :through => :request_items
  has_many :request_items, dependent: :destroy

  # Relationship with CustomField
  has_many :custom_fields, -> { uniq }, :through => :item_custom_fields
  has_many :item_custom_fields, dependent: :destroy

  # Relation with Logs
  has_many :logs, dependent: :destroy

  attr_accessor :curr_user

	after_create {
    create_custom_fields_for_items(self.id)
  	create_log("created", false, self.quantity)
	}

	after_update {
		create_log_on_quantity_change()
		create_log_on_desc_update()
	}


  def self.tagged_with_all(tag_filters)
    if tag_filters.length == 0
      all
    else
      joins(:tags).where('tags.name IN (?)', tag_filters).group('items.id').having('count(*)=?', tag_filters.count)
    end
  end

  def self.tagged_with_none(tag_filters)
    if tag_filters.length == 0
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

  def update_by_subrequest(subrequest, request_type)
    case request_type
    when "disbursement"
      self[:quantity] = self[:quantity] - subrequest[:quantity]
    when "acquisition"
      self[:quantity] = self[:quantity] + subrequest[:quantity]
    when "destruction"
      self[:quantity] = self[:quantity] - subrequest[:quantity]
    else
      self[:quantity]
    end
  end

	def create_log_on_desc_update()
		if (self.unique_name != self.unique_name_was || self.description != self.description_was || self.model_number != self.model_number_was)
			create_log("desc_updated", true, self.quantity - self.quantity_was)
		end
	end

	def create_log_on_quantity_change()
		quantity_increase = self.quantity - self.quantity_was
		if quantity_increase != 0
			# TODO: in future: grab reason for change!!
			create_log("acquired_quantity", false, quantity_increase)
		end
	end

	def create_log(action, desc_changed, quan_change)
		if self.curr_user.nil?
			curr = nil
		else
			curr = self.curr_user.id
		end

		old_name = ""
		old_desc = ""
		old_model = ""

		if (desc_changed)
			old_name = self.unique_name_was
			old_desc = self.description_was
			old_model = self.model_number_was
		end

		log = Log.new(:user_id => curr, :log_type => "item")
		log.save!
		itemlog = ItemLog.new(:log_id => log.id, :item_id => self.id, :action => action, :quantity_change => quan_change, :old_name => old_name, :new_name => self.unique_name, :old_desc => old_desc, :new_desc => self.description, :old_model_num => old_model, :new_model_num => self.model_number)
		itemlog.save!
	end

  private

  def create_custom_fields_for_items(item_id)
    CustomField.all.each do |cf|
      ItemCustomField.create!(item_id: item_id, custom_field_id: cf.id,
                              short_text_content: nil,
                              long_text_content: nil,
                              integer_content: nil,
                              float_content: nil)
    end
  end
end
