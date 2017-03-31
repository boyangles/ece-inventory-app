class Item < ApplicationRecord
	include Loggable
	
	ITEM_STATUS_OPTIONS = %w(active deactive)
	
	enum status: {
		active: 0,
		deactive: 1
	}

	enum last_action: {
		acquired_or_destroyed_quantity: 0,
		administrative_correction: 1,
		disbursed: 2,
		created: 3,
		deleted: 4,
		description_updated: 5,
		loaned: 6,
		returned: 7,
		disbursed_from_loan: 8
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
  accepts_nested_attributes_for :item_custom_fields


  # Relation with Logs
  has_many :logs

  attr_accessor :curr_user
  attr_accessor :tag_list
  attr_accessor :tags_list


  after_create {
    create_custom_fields_for_items(self.id)
  	create_log("created", self.quantity)
	}

	after_update {
		create_log_on_quantity_change()
		create_log_on_desc_update()
		create_log_on_destruction()
	}

	##
  # ITEM-6: import_item
  # Importing a item and associated properties
  #
  # Input: item in JSON format
  # Output: Outputted Item
  def self.import_item(item_hash)
    raise Exception.new('Input Tags must be in array form') unless
        item_hash['tags'] && item_hash['tags'].kind_of?(Array)
    raise Exception.new('Input Custom Fields must be in array form') unless
        item_hash['custom_fields'] && item_hash['custom_fields'].kind_of?(Array)

    # Item creation paired with tag creation and custom_field creation as a single transaction
    # Executes belows as a single transaction
    ActiveRecord::Base.transaction do
      item = Item.new(unique_name: item_hash['unique_name'],
                      quantity: item_hash['quantity'],
                      model_number: item_hash['model_number'],
                      description: item_hash['description'],
                      last_action: 0)
      raise Exception.new("Item creation error. The errors hash is: #{item.errors.full_messages}. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless item.save

      item_hash['tags'].each do |tag|
        if !Tag.exists?(name: tag)
          new_tag = Tag.new(name: tag)
          raise Exception.new("Tag creation error. The invalid tag is: #{tag}. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless new_tag.save
        end

        input_tag = Tag.find_by(name: tag)
        raise Exception.new("Tag find error. Cannot find tag by name: #{tag}. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless input_tag
        item.tags << input_tag
      end

      item_hash['custom_fields'].each do |custom_field|
        cf = CustomField.find_by(field_name: custom_field['name'])
        raise Exception.new("Custom Field named: #{custom_field['name']} -- cannot be found. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless cf

        icf = ItemCustomField.find_by(item_id: item.id, custom_field_id: cf.id)
        raise Exception.new("Custom Field named: #{cf[:field_name]} -- associated with Item named: #{item[:unique_name]} -- cannot be found. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless icf

        raise Exception.new("Custom Field named: #{cf[:field_name]} -- associated with Item named: #{item[:unique_name]} -- has trouble updating to the value: #{custom_field['value']}. Check the type! Item_Custom_Field error hash is: #{icf.errors.full_messages}. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless
            icf.update_attributes(CustomField.find_icf_field_column(cf.id) => custom_field['value'])
      end

      item
    end
  end

  ##
  # ITEM-7: bulk_import
  # Importing bulk items
  #
  # Input: items in JSON format
  # Output: Outputted Items
  def self.bulk_import(items_as_json)
    raise Exception.new('Invalid JSON format. Please recheck the syntax of your input!!') unless
        valid_json?(items_as_json)

    items_hash = JSON.parse(items_as_json)

    ActiveRecord::Base.transaction do
      items_hash.each do |item_hash|
        import_item(item_hash)
      end
    end
  end

  def self.tagged_with_all(tag_filters)
    if tag_filters.length == 0
      all
    else
      puts "TAG FILTERS HERE"
      puts tag_filters
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

	def create_log_on_quantity_change()
		if self.quantity_was.nil?
			return
		end

		quantity_increase = self.quantity - self.quantity_was
		if (quantity_increase != 0 && (self.administrative_correction? || self.acquired_or_destroyed_quantity? ))
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
			create_log("description_updated", self.quantity)
		end
	end

	def deactivate!
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

  private
  def self.valid_json?(json)
    begin
      JSON.parse(json)
      return true
    rescue JSON::ParserError => e
      return false
    end
  end
end
