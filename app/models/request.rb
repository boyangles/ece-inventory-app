class Request < ApplicationRecord
  include Filterable, Subscribable

  #relationship with items
  has_many :items,  -> {uniq}, :through => :request_items
  has_many :request_items, dependent: :destroy

  belongs_to :user

  accepts_nested_attributes_for :request_items, allow_destroy: true # :reject_if => lambda {|a| a[:item_id].blank?}

  # Default scopes
  default_scope -> { order(created_at: :desc) }

  # Data Options:
  STATUS_OPTIONS = %w(outstanding approved denied cart cancelled)

  enum request_type: {
      disbursement: 0,
      acquisition: 1,
      destruction: 2
  }

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
    create_cart_on_status_change_from_cart(self.user_id)
		log_on_status_change()
  }

  # Validations
  validates :request_type, :inclusion => { :in => REQUEST_TYPE_OPTIONS }
  validates :status, :inclusion => { :in => STATUS_OPTIONS }
  validates :user_id, presence: true

  def has_status_change_to_approved?(request_params)
    self.outstanding? && request_params[:status] == 'approved' || self.cart? && request_params[:status] == 'approved'
  end

	def has_status_change_to_outstanding?(request_params)
		self.cart? && request_params[:status] == 'outstanding'
	end

	def are_request_details_valid?
    self.request_items.each do |sub_request|
      @item = Item.find(sub_request.item_id)

      if @item.deactive?
        return false, @item.unique_name  + " doesn't exist anymore! Cannot be disbursed."
      elsif Request.component_oversubscribed?(@item, self, sub_request)
        return false, "Item named #{@item.unique_name} is oversubscribed. Requested #{sub_request.quantity}, but only has #{@item.quantity}."
	    end
    end

    return true, ""
  end

	def are_items_valid?
    self.request_items.each do |sub_request|
      @item = Item.find(sub_request.item_id)

      if @item.deactive?
        return false, @item.unique_name  + " doesn't exist anymore! Please remove from cart."
	    end
    end

    return true, ""
  end



  private

  def cart_cannot_be_duplicated
    if self.cart? &&
        Request.where(:user_id => self.user_id).where(:status => :cart).exists? &&
        self.status_was != self.status
      errors.add(:user_id, 'There cannot be two cart requests for a single user')
    end
  end

  def create_cart_on_status_change_from_cart(id)
    old_status = self.status_was
    new_status = self.status
		cond2 = old_status == 'cart' && old_status != new_status
		cond1 = self.user_id_was != self.user_id

    if cond1
      @cart = Request.new(:status => :cart, :user_id => self.user_id_was, :reason => 'TBD')
      @cart.save!
		elsif cond2
			@cart = Request.new(:status => :cart, :user_id => self.user_id, :reason=> 'TBD')
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
#		elsif old_status == 'cart' && new_status == 'approved' #admin direct
#		create_log(new_status)
#		elsif old_status == 'outstanding' && new_status != old_status
#			create_log(new_status)
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

end
