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
  STATUS_OPTIONS = %w(outstanding approved denied cart)

  enum request_type: {
      disbursement: 0,
      acquisition: 1,
      destruction: 2
  }

  enum status: {
    outstanding: 0,
    approved: 1,
    denied: 2,
    cart: 3
  }

  scope :user_id, -> (user_id) { where user_id: user_id }
  scope :status, -> (status) { where status: status }

  after_update {
    create_cart_on_status_change_from_cart(self.user_id)
  }

  # Validations
  validates :request_type, :inclusion => { :in => REQUEST_TYPE_OPTIONS }
  validates :status, :inclusion => { :in => STATUS_OPTIONS }
  validates :user_id, presence: true
  validate :cart_cannot_be_duplicated

  def has_status_change_to_approved?(request_params)
    self.outstanding? && request_params[:status] == 'approved'
  end

  def are_request_details_valid?
    self.request_items.each do |sub_request|
      @item = Item.find(sub_request.item_id)

      if !@item
        return false, "Item doesn't exist anymore!"
      elsif Request.component_oversubscribed?(@item, self, sub_request)
        return false, "Item named #{@item.unique_name} is oversubscribed. Requested #{sub_request.quantity}, but only has #{@item.quantity}."
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

    if old_status == 'cart' && old_status != new_status
      @cart = Request.new(:status => :cart, :user_id => id, :reason => 'TBD')
      @cart.save!
    end
  end
end
