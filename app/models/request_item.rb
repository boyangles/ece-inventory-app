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
  scope :user_id, -> (user_id) { joins(:request).where(requests: { user_id: user_id }) }
  scope :request_type, -> (request_type) {
    case request_type
      when 'disbursement'
        where("(quantity_loan <= 0 AND quantity_return <= 0 AND quantity_disburse > 0)")
      when 'loan'
        where("(quantity_loan <= 0 AND quantity_return > 0 AND quantity_disburse <= 0) OR
               (quantity_loan > 0 AND quantity_return <= 0 AND quantity_disburse <= 0) OR
               (quantity_loan > 0 AND quantity_return > 0 AND quantity_disburse <= 0)")
      when 'mixed'
        where("(quantity_loan <= 0 AND quantity_return <= 0 AND quantity_disburse <= 0) OR
               (quantity_loan <= 0 AND quantity_return > 0 AND quantity_disburse > 0) OR
               (quantity_loan > 0 AND quantity_return <= 0 AND quantity_disburse > 0) OR
               (quantity_loan > 0 AND quantity_return > 0 AND quantity_disburse > 0)")
      else
        none
    end
  }
  scope :quantity_loan, -> (quantity_loan) { where quantity_loan: quantity_loan }
  scope :quantity_disburse, -> (quantity_disburse) { where quantity_disburse: quantity_disburse }
  scope :quantity_return, -> (quantity_return) { where quantity_return: quantity_return }

  attr_readonly :request_id, :item_id

  before_validation {
    self.quantity_disburse = (self.quantity_disburse.blank?) ?  0 : self.quantity_disburse
    self.quantity_return = (self.quantity_return.blank?) ? 0 : self.quantity_return
    self.quantity_loan = (self.quantity_loan.blank?) ? 0 : self.quantity_loan
  }

  validates :quantity_loan, presence: true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :quantity_disburse, presence: true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :quantity_return, presence: true, :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  # validates :request_type, :inclusion => { :in => REQUEST_TYPE_OPTIONS }
  #validate :request_type_quantity_validation

  validate  :validates_loan_and_disburse_not_zero

  ##
  # REQ-ITEM-1: oversubscribed?
  # Determines if a subrequest is valid or invalid
  #
  # Input: N/A
  # Output: true/false
  def oversubscribed?
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
    disbursement_quantity = (self[:quantity_disburse].nil?) ? 0 : self[:quantity_disburse]
    loan_quantity = (self[:quantity_loan].nil?) ? 0 : self[:quantity_loan]

    @item = self.item
    @item.update!(:quantity => item[:quantity] - disbursement_quantity - loan_quantity)
    @item.update!(:quantity_on_loan => item[:quantity_on_loan] + loan_quantity)
  end

  ##
  # REQ-ITEM-3: rollback_fulfill_subrequest
  # The subaction that happens when a request changes from 'approved' to something else or when a request_item is
  # outright deleted with old request status 'approved'
  def rollback_fulfill_subrequest
    disbursement_quantity = (self[:quantity_disburse].nil?) ? 0 : self[:quantity_disburse]
    loan_quantity = (self[:quantity_loan].nil?) ? 0 : self[:quantity_loan]

    @item = self.item
    @item.update!(:quantity => item[:quantity] + disbursement_quantity + loan_quantity)
    @item.update!(:quantity_on_loan => item[:quantity_on_loan] - loan_quantity)
  end

  ##
  # REQ-ITEM-4: return_subrequest
  def return_subrequest(to_return)
    quantity_to_return = (to_return.nil?) ? 0 : to_return

    @item = self.item
    self.update!(:quantity_loan => self[:quantity_loan] - quantity_to_return)
    self.update!(:quantity_return => self[:quantity_return] + quantity_to_return)

    @item.update!(:quantity => item[:quantity] + quantity_to_return)
    @item.update!(:quantity_on_loan => item[:quantity_on_loan] - quantity_to_return)
  end

  ##
  # REQ-ITEM-5: disburse_loaned_subrequest
  def disburse_loaned_subrequest(to_disburse)
    quantity_to_disburse = (to_disburse.nil?) ? 0 : to_disburse

    @item = self.item
    self.update!(:quantity_loan => self[:quantity_loan] - quantity_to_disburse)
    self.update!(:quantity_disburse => self[:quantity_disburse] + quantity_to_disburse)
    @item.update!(:quantity_on_loan => item[:quantity_on_loan] - quantity_to_disburse)
  end

  def determine_subrequest_type
    loan_quantity = (self[:quantity_loan].nil?) ? 0 : self[:quantity_loan]
    return_quantity = (self[:quantity_return].nil?) ? 0 : self[:quantity_return]
    disburse_quantity = (self[:quantity_disburse].nil?) ? 0 : self[:quantity_disburse]

    if loan_quantity <= 0 && return_quantity <= 0 && disburse_quantity <= 0
      return 'mixed'
    elsif loan_quantity <= 0 && return_quantity <= 0 && disburse_quantity > 0
      return 'disbursement'
    elsif loan_quantity <= 0 && return_quantity > 0 && disburse_quantity <= 0
      return 'loan'
    elsif loan_quantity <= 0 && return_quantity > 0 && disburse_quantity > 0
      return 'mixed'
    elsif loan_quantity > 0 && return_quantity <= 0 && disburse_quantity <= 0
      return 'loan'
    elsif loan_quantity > 0 && return_quantity <= 0 && disburse_quantity > 0
      return 'mixed'
    elsif loan_quantity > 0 && return_quantity > 0 && disburse_quantity <= 0
      return 'loan'
    elsif loan_quantity > 0 && return_quantity > 0 && disburse_quantity > 0
      return 'mixed'
    else
      return 'mixed'
    end
  end

  ## Validations

  def validates_loan_and_disburse_not_zero
    errors.add(:base, "Loan and Disburse cannot both be 0") if quantity_disburse == 0 && quantity_loan == 0
  end

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
