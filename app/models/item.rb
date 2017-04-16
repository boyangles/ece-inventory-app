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
      disbursed_from_loan: 8,
      backfill_requested: 9,
      backfill_request_approved: 10,
      backfill_request_denied: 11,
      backfill_request_satisfied: 12,
      backfill_request_failed: 13,
      convert_to_assets: 14,
      convert_to_global: 15
  }

  validates :unique_name, presence: true, length: { maximum: 50 },
            uniqueness: { case_sensitive: false }
  validates :quantity, presence: true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :description, length: { maximum: 255 }
  validates :status, :inclusion => { :in => ITEM_STATUS_OPTIONS }
  validates :last_action, :inclusion => { :in => ITEM_LOGGED_ACTIONS }
  validates :minimum_stock,:numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :has_stocks, :inclusion => {:in => [true, false]}

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

  # Per Asset
  has_many :stocks, dependent: :destroy

  # Relation with Logs
  has_many :logs

  attr_accessor :curr_user
  attr_accessor :tag_list
  attr_accessor :tags_list

  ### CALLBACKS ###

  after_create {
    initialize_stocks
    create_custom_fields_for_items(self.id)
    create_log("created", self.quantity)
  }

  after_update {
    create_log_on_quantity_change()
    create_log_on_desc_update()
    create_log_on_destruction()
  	create_log_on_stocks_status_change
	}

  ##
  # ITEM-6: import_item
  # Importing a item and associated properties
  #
  # Input: item in JSON format
  # Output: Outputted Item
  def self.import_item(item_hash)
    item_hash['tags'] = [] if item_hash['tags'].blank?
    item_hash['custom_fields'] = [] if item_hash['custom_fields'].blank?
    item_hash['assets'] = [] if item_hash['assets'].blank?

    raise Exception.new('Input Tags must be in array form') unless
        item_hash['tags'] && item_hash['tags'].kind_of?(Array)
    raise Exception.new('Input Custom Fields must be in array form') unless
        item_hash['custom_fields'] && item_hash['custom_fields'].kind_of?(Array)
    raise Exception.new('Input Asset Array must be in array form') unless
        item_hash['assets'] && item_hash['assets'].kind_of?(Array)

    # Item creation paired with tag creation and custom_field creation as a single transaction
    # Executes belows as a single transaction
    ActiveRecord::Base.transaction do
      item = Item.new(unique_name: item_hash['unique_name'],
                      quantity: item_hash['quantity'],
                      model_number: item_hash['model_number'],
                      description: item_hash['description'],
                      has_stocks: false,
                      last_action: 0)
      raise Exception.new("Item creation error. The errors hash is: #{item.errors.full_messages}. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless
          item.save

      item_hash['tags'].each do |tag|
        if !Tag.exists?(name: tag)
          new_tag = Tag.new(name: tag)
          raise Exception.new("Tag creation error. The invalid tag is: #{tag}. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless
              new_tag.save
        end

        input_tag = Tag.find_by(name: tag)
        raise Exception.new("Tag find error. Cannot find tag by name: #{tag}. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless
            input_tag
        item.tags << input_tag
      end

      item_hash['custom_fields'].each do |custom_field|
        cf = CustomField.find_by(field_name: custom_field['name'])
        raise Exception.new("Custom Field named: #{custom_field['name']} -- cannot be found. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless
            cf

        icf = ItemCustomField.find_by(item_id: item.id, custom_field_id: cf.id)
        raise Exception.new("Custom Field named: #{cf[:field_name]} -- associated with Item named: #{item[:unique_name]} -- cannot be found. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless
            icf

        raise Exception.new("Custom Field named: #{cf[:field_name]} -- associated with Item named: #{item[:unique_name]} -- has trouble updating to the value: #{custom_field['value']}. Check the type! Item_Custom_Field error hash is: #{icf.errors.full_messages}. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless
            icf.update_attributes(CustomField.find_icf_field_column(cf.id) => custom_field['value'])
      end

      ## Exceptions related to stocks
      # Number of stocks that are available must equal to the quantity if hash_stocks is true
      raise Exception.new("The number of assets specified must equal the specified quantity of an item that is classified as an asset-item. Item quantity for item: #{item.unique_name} is: #{item.quantity}. Asset array length is #{item_hash['assets'].count}. Item hash is: #{JSON.pretty_generate(item_hash)}.") if
          item_hash['has_stocks'] && item.quantity != item_hash['assets'].count

      if item_hash['has_stocks']
        item_hash['assets'].each do |stock_serial_tag|
          new_stock = Stock.new(:item_id => item.id, :available => true, :serial_tag => stock_serial_tag)
          raise Exception.new("Asset creation error. The asset hash is: #{new_stock.errors.full_messages}. The asset serial tag is: #{stock_serial_tag}. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless
              new_stock.save
        end

        raise Exception.new("There are issues with specifying assets for an item. The item error is: #{item.errors.full_messages}. Item hash is: #{JSON.pretty_generate(item_hash)}.") unless
            item.update(:has_stocks => item_hash['has_stocks'])
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

  def convert_to_stocks!
    raise Exception.new("Cannot convert to assets if this item is already specified as having assets!") if self.has_stocks

    begin
      ActiveRecord::Base.transaction do
        (1..self.quantity).each do
          Stock.create!(:item_id => self.id, :available => true)
        end

        (1..self.quantity_on_loan).each do
          Stock.create!(:item_id => self.id, :available => false)
        end
				
        self.has_stocks = true
        self.save!
      end
    end

    Stock.where(item_id: self.id)
  end

  def convert_to_stocks
    return false if self.has_stocks

    begin
      ActiveRecord::Base.transaction do
        for i in 1..self.quantity do
          Stock.create!(:item_id => self.id, :available => true)
        end

        for i in 1..self.quantity_on_loan do
          Stock.create!(:item_id => self.id, :available => false)
        end

        self.has_stocks = true
        self.save!
      end

      return true
    rescue Exception => e
      return false
    end
  end

  def initialize_stocks
    return false unless self.has_stocks && Stock.where(:item_id => self.id).count == 0

    begin
      ActiveRecord::Base.transaction do
        for i in 1..self.quantity do
          Stock.create!(:item_id => self.id, :available => true)
        end

        for i in 1..self.quantity_on_loan do
          Stock.create!(:item_id => self.id, :available => false)
        end
      end

      return true

    rescue Exception => e
      return false
    end
  end

  # Converts stocked items back to singular global item
  def convert_to_global
    return false unless self.has_stocks

    Stock.destroy_all(item_id: self.id)
    self.has_stocks = false
    self.save!

  end

  def convert_to_global!
    raise Exception.new("Cannot convert back assets for an item if that item is already specified as not having assets!") unless self.has_stocks

    Stock.destroy_all(item_id: self.id)
    self.has_stocks = false
    self.save!

    self
  end

  def convert_quantity_to_stocks(num_to_create)
    return false unless self.has_stocks

    for i in 1..num_to_create do
      Stock.create!(:item_id => self.id, :available => true)
    end
    return true
  end

  def delete_stock(stock)
    Stock.transaction do
      if !stock.available
        self.quantity_on_loan = self.quantity_on_loan - 1
      end
      self.quantity = self.quantity - 1
      stock.destroy!
      self.save!
    end
  end

  def destroy_stocks_by_serial_tags!(serial_tag_list)
    Stock.transaction do
      serial_tag_list.each do |st|
        tag = Stock.where(serial_tag: st)
        if tag.available
          self.quantity -= 1
        else
          self.quantity_on_loan -= 1
        end
      end
      # Stock.destroy_all(:serial_tag => serial_tag_list)
      # self.quantity -= serial_tag_list.size
      self.save!
    end
  end

  def delete_stocks_through_request_by_list(request_item)

    # These are now RequestItemStock hashes
    serial_tags_loan = RequestItemStock.where(request_item_id: request_item.id, status: 'loan')
    serial_tags_disburse = RequestItemStock.where(request_item_id: request_item.id, status: 'disburse')

    raise Exception.new("Serial Tags for loans size must equal to the specified loan size requested") unless request_item.quantity_loan == serial_tags_loan.size
    raise Exception.new("Serial Tags for disburse size must equal to the specified disburse size requested ") unless request_item.quantity_disburse == serial_tags_disburse.size



    Stock.transaction do
      serial_tags_disburse.each do |st|
        stock = Stock.find(st.stock_id)
        raise Exception.new("Error in finding requested stock. Input serial tag is: #{st.stock.serial_tag}") unless stock
        stock.destroy!
        self.quantity = self.quantity - 1
      end

      serial_tags_loan.each do |st|
        stock = Stock.find(st.stock_id)
        raise Exception.new("Error in finding requested stock. Input serial tag is: #{st.stock.serial_tag}") unless stock
        raise Exception.new("Stock requested for loan is not available: #{st.stock.serial_tag}") unless stock.available

        stock.available = false
        raise Exception.new("Stock failed to save. #{stock.errors.full_messages}.") unless stock.save

        self.quantity = self.quantity - 1
        self.quantity_on_loan = self.quantity_on_loan + 1
      end
      raise Exception.new("Item cannot be saved. Item errors are: #{self.errors.full_messages}") unless self.save
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

  def self.minimum_stock
    where("minimum_stock > quantity")
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

	def create_log_on_stocks_status_change
		if has_stocks_was != has_stocks && has_stocks_was != nil
			if has_stocks
				create_log("convert_to_assets", 0)
			else
				create_log("convert_to_global", 0)
			end
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

  def create_stock!(serial_tag)
    Item.transaction do
      stock = Stock.create!(serial_tag: serial_tag, item_id: self.id)
      self.update_item_quantity_on_stock_creation
      stock
    end
  end

  def update_item_quantity_on_stock_creation
    self.quantity += 1
    self.save!
  end

  def self.is_valid_integer(input)
    input.to_i.to_s == input
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


  def self.valid_json?(json)
    begin
      JSON.parse(json)
      return true
    rescue JSON::ParserError => e
      return false
    end
  end


end
