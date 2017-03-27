class Request < ApplicationRecord
  include Filterable

  #relationship with items
  has_many :items,  -> {uniq}, :through => :request_items
  has_many :request_items, dependent: :destroy

  belongs_to :user

  accepts_nested_attributes_for :request_items, allow_destroy: true # :reject_if => lambda {|a| a[:item_id].blank?}

  # Default scopes
  default_scope -> { order(created_at: :desc) }

  # Data Options:
  STATUS_OPTIONS = %w(outstanding approved denied cart cancelled)

  enum status: {
    outstanding: 0,
    approved: 1,
    denied: 2,
    cart: 3,
    cancelled: 4
  }

  scope :user_id, -> (user_id) { where user_id: user_id }
  scope :status, -> (status) { where status: status }
	attr_accessor :curr_user

  after_update {
    update_respective_items
    create_cart_on_status_change_from_cart(self.user_id)
		log_on_status_change()
  }

  # Validations
  validates :status, :inclusion => { :in => STATUS_OPTIONS }
  validates :user_id, presence: true
  validates :request_initiator, presence: true
	validate :cart_cannot_be_duplicated

  def determine_request_type
    current_request_type = 'indeterminate'
    self.request_items.each do |request_item|
      subrequest_type = request_item.determine_subrequest_type
      case subrequest_type
        when 'disbursement'
          return 'mixed' if current_request_type == 'loan'
          current_request_type = 'disbursement'
        when 'loan'
          return 'mixed' if current_request_type == 'disbursement'
          current_request_type = 'loan'
        else # mixed
          return 'mixed'
      end
    end

    current_request_type
  end

  private
  def cart_cannot_be_duplicated
    if self.cart? &&
        Request.where(:request_initiator => self.user_id).where(:status => :cart).exists? &&
        self.status_was != self.status
      errors.add(:user_id, 'There cannot be two cart requests for a single user')
    end
  end

  ## Callbacks

  def update_respective_items
    if self.status_was != 'approved' && self.status == 'approved'
      self.request_items.each do |req_item|
        begin
          req_item.fulfill_subrequest
          if !req_item.quantity_disburse.nil? 
            if req_item.quantity_disburse. > 0
              create_item_log("disbursed", req_item, req_item.quantity_disburse)
            end
          end
          if !req_item.quantity_loan.nil? && req_item.quantity_loan > 0
            create_item_log("loaned", req_item, req_item.quantity_loan)
          end
        rescue Exception => e
          raise Exception.new("The following request for item: #{req_item.item.unique_name} cannot be fulfilled. Perhaps it is oversubscribed? The current quantity of the item is: #{req_item.item.quantity}")
        end
      end
    elsif self.status_was == 'approved' && self.status != 'approved'
      self.request_items.each do |req_item|
        begin
          req_item.rollback_fulfill_subrequest
        rescue Exception => e
          raise Exception.new("The following request for item: #{req_item.item.unique_name} cannot be fulfilled. Perhaps it is oversubscribed? The current quantity of the item is: #{req_item.item.quantity}")
        end
      end
    end
  end

  def create_cart_on_status_change_from_cart(id)
    old_status = self.status_was
    new_status = self.status
		cond2 = old_status == 'cart' && old_status != new_status
		cond1 = self.user_id_was != self.user_id

    if cond1
      @cart = Request.new(:status => :cart, :user_id => self.user_id_was, :request_initiator => self.user_id_was)
      @cart.save!
		elsif cond2
			@cart = Request.new(:status => :cart, :user_id => self.user_id, :request_initiator => self.user_id)
			@cart.save!
    end
  end

	def log_on_status_change()
		old_status = self.status_was
		new_status = self.status

		if old_status == 'cart' && new_status == 'outstanding' 
			create_log("placed")
		elsif old_status != new_status
			create_log(new_status)
		end

	end
	
	def create_log(action)
		if self.curr_user.nil?
			curr = nil
		else
			curr = self.curr_user.id
		end

		if (action=="outstanding")
			action = "placed"
		end

		log = Log.new(:user_id => curr, :log_type => "request")
		log.save!
		reqlog = RequestLog.new(:log_id => log.id, :request_id => self.id, :action => action)
		reqlog.save!
	end 

  def create_item_log(action, req_item, quantity_change)
    itemo = req_item.item
    itemo.update!(:last_action => action)

    if self.curr_user.nil?
      curr = nil
    else
      curr = self.curr_user.id
    end

    old_name = ""
    old_desc = ""
    old_model = ""

    if itemo.unique_name_was != itemo.unique_name
      old_name = itemo.unique_name_was
    end
    if itemo.description_was != itemo.description
      old_desc = itemo.description_was
    end
    if itemo.model_number_was != itemo.model_number
      old_model = itemo.model_number_was
    end
    
    log = Log.new(:user_id => curr, :log_type => 'item')
    log.save!
    itemlog = ItemLog.new(:log_id => log.id, :item_id => itemo.id, :action => action, :quantity_change => quantity_change, :old_name => old_name, :new_name => itemo.unique_name, :old_desc => old_desc, :new_desc => itemo.description, :old_model_num => old_model, :new_model_num => itemo.model_number, :curr_quantity => itemo.quantity, :affected_request => self.id)
    itemlog.save!
  end

end
