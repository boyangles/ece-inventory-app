class Item < ApplicationRecord
	include Loggable
	
	ITEM_STATUS_OPTIONS = %w(active deactive)
	
	enum status: {
		active: 0,
		deactive: 1
	}

	enum last_action: {
		acquired_destroyed_quantity: 0,
		admin_corr_quantity: 1,
		disbursed: 2,
		created: 3,
		deleted: 4,
		desc_updated: 5
	}
	
  validates :unique_name, presence: true, length: { maximum: 50 },
            uniqueness: { case_sensitive: false }
  validates :quantity, presence: true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :description, length: { maximum: 255 }
	validates :status, :inclusion => { :in => ITEM_STATUS_OPTIONS }
	validates :last_action, :inclusion => { :in => ITEM_LOGGED_ACTIONS }

  # Relation with Tags
  has_many :tags, -> { distinct },  :through => :item_tags
  has_many :item_tags

  # Relation with Requests
  has_many :requests, -> { distinct },  :through => :request_items
  has_many :request_items, dependent: :destroy

  # Relationship with CustomField
  has_many :custom_fields, -> { distinct }, :through => :item_custom_fields
  has_many :item_custom_fields, dependent: :destroy

  # Relation with Logs
  has_many :logs, dependent: :destroy

  attr_accessor :curr_user

	after_create {
    create_custom_fields_for_items(self.id)
  	create_log("created", self.quantity)
	}

	after_update {
		create_log_on_quantity_change()
		create_log_on_desc_update()
		create_log_on_destruction()
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

	def self.filter_active
		where(status: 'active')
	end

  def update_by_subrequest(subrequest, request_type)
    case request_type
    when "disbursement"
      self[:quantity] = self[:quantity] - subrequest[:quantity]
			self[:last_action] = 'disbursed'
    when "acquisition"
      self[:quantity] = self[:quantity] + subrequest[:quantity]
    when "destruction"
      self[:quantity] = self[:quantity] - subrequest[:quantity]
    else
      self[:quantity]
    end
  end

	def create_log_on_quantity_change()
		if self.quantity_was.nil?
			return
		end

		quantity_increase = self.quantity - self.quantity_was
		if quantity_increase != 0 && self.last_action != "disbursed"
			create_log(self.last_action, quantity_increase)
		end
	end

	def create_log_on_destruction()

		if self.status == 'deactive' && self.status_was == 'active'
			create_log("deleted", self.quantity)
		end
	end
	
	def create_log(action, quan_change)
		if self.curr_user.nil?
			curr = nil
		else
			curr = self.curr_user.id
		end
		old_name = ""
		old_desc = ""
		old_model = ""

		if self.unique_name_was != self.unique_name
			old_name = self.unique_name_was
		end
		if self.description_was != self.description
			old_desc = self.description_was
		end
		if self.model_number_was != self.model_number
			old_model = self.model_number_was
		end
		
		log = Log.new(:user_id => curr, :log_type => 'item')
		log.save!
		itemlog = ItemLog.new(:log_id => log.id, :item_id => self.id, :action => action, :quantity_change => quan_change, :old_name => old_name, :new_name => self.unique_name, :old_desc => old_desc, :new_desc => self.description, :old_model_num => old_model, :new_model_num => self.model_number, :curr_quantity => self.quantity)
		itemlog.save!
	end


	def create_log_on_desc_update()
		if (self.unique_name_was != self.unique_name || self.description_was != self.description || self.model_number_was != self.model_number)
			create_log("desc_updated", self.quantity)
		end
	end

	def deactivate
		self.status = 'deactive'
		self.save!
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
