class RequestItem < ApplicationRecord
  include Filterable

  belongs_to :request
  belongs_to :item

  ## Constants
  REQUEST_TYPE_OPTIONS = %w(disbursement loan mixed)

  enum request_type: {
      disbursement: 0,
      loan: 1,
      mixed: 2
  }

  # Scopes for filtering
  scope :request_id, -> (request_id) { where request_id: request_id }
  scope :item_id, -> (item_id) { where item_id: item_id }
  scope :quantity_loan, -> (quantity_loan) { where quantity_loan: quantity_loan }
  scope :quantity_disburse, -> (quantity_disburse) { where quantity_disburse: quantity_disburse }
  scope :quantity_return, -> (quantity_return) { where quantity_return: quantity_return }

  attr_readonly :request_id, :item_id

  validates :quantity_loan, presence: true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, :allow_nil => true
  validates :quantity_disburse, presence: true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, :allow_nil => true
  validates :quantity_return, presence: true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}, :allow_nil => true
  validates :request_type, :inclusion => { :in => REQUEST_TYPE_OPTIONS }
  #validate :request_type_quantity_validation

  ##
  # REQ-ITEM-1: oversubscribed?
  # Determines if a subrequest is valid or invalid
  #
  # Input: N/A
  # Output: true/false
  def oversubscribed?

    #case self[:request_type]
    #  when 'disbursement'
    #    diff = item[:quantity] - self[:quantity_disburse]
    #  when 'loan'
    #    diff = item[:quantity] - self[:quantity_loan]
    #  else # when 'mixed'
    #    diff = item[:quantity] - (self[:quantity_disburse] + self[:quantity_loan])
    #end

    diff = item[:quantity] - (self[:quantity_disburse] + self[:quantity_loan])

    return diff < 0
  end

  ##
  # REQ-ITEM-2: fulfill_subrequest
  # The subaction that happens when a request changes form another status to 'approved', or when a request_item is
  # outright created with corresponding request status 'approved'
  #
  # Input: N/A
  # Output: @item upon success
  def fulfill_subrequest
    @item = self.item
    @item.update(:quantity => item[:quantity] - self[:quantity_disburse] - self[:quantity_loan])

    #case self[:request_type]
    #  when 'disbursement'
    #    @item.update(:quantity => item[:quantity] - self[:quantity_disburse])
    #  when 'loan'
    #    @item.update(:quantity => item[:quantity] - self[:quantity_loan])
    #  else # when 'mixed'
    #    @item.update(:quantity => item[:quantity] - self[:quantity_disburse] - self[:quantity_loan])
    #end
  end

  ##
  # REQ-ITEM-3: rollback_fulfill_subrequest
  # The subaction that happens when a request changes from 'approved' to something else or when a request_item is
  # outright deleted with old request status 'approved'
  def rollback_fulfill_subrequest
    @item = self.item
    @item.update(:quantity => item[:quantity] + self[:quantity_disburse] + self[:quantity_loan])

    #case self[:request_type]
    #  when 'disbursement'
    #    @item.update(:quantity => item[:quantity] + self[:quantity_disburse])
    #  when 'loan'
    #    @item.update(:quantity => item[:quantity] + self[:quantity_loan])
    #  else # when 'mixed'
    #    @item.update(:quantity => item[:quantity] + self[:quantity_disburse] + self[:quantity_loan])
    #end
  end

  ## Validations
  def request_type_quantity_validation
    case self[:request_type]
      when 'disbursement'
        errors.add(:quantity_disburse, "cannot be negative") unless quantity_disburse > -1
      when 'loan'
        errors.add(:quantity_loan, "cannot be negative") unless quantity_loan > -1
        errors.add(:quantity_return, "cannot be negative") unless quantity_return > -1
      else # when 'mixed'
        errors.add(:quantity_disburse, "cannot be negative") unless quantity_disburse > -1
        errors.add(:quantity_loan, "cannot be negative") unless quantity_loan > -1
        errors.add(:quantity_return, "cannot be negative") unless quantity_return > -1
    end
  end
end
