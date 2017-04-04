class Backfill < ApplicationRecord
	include Filterable

	belongs_to :request_item

	## Constants
	BF_STATUS_OPTIONS = %w(in_cart, outstanding, in_transit, denied, satisfied, failed)

	enum bf_status: {
		in_cart: 0,
		outstanding: 1,
		in_transit: 2,
		denied: 3,
		satisfied: 4,
		failed: 5
	}

	enum origin: {
		direct_request: 0,
		converted_loan: 1
	}

	scope :bf_status, -> (bf_status) { where bf_status: bf_status }

	validates :bf_status, :inclusion => { :in => BF_STATUS_OPTIONS }
	validates :quantity, presence: true, :numericality => {:only_integer => true, :greater_than => 0}

	after_update {
		status_change_to_transit
		status_change_to_satisfied
		status_change_to_failed
	}

	def status_change_to_transit
		item = self.request_item.item

		item.update!(:quantity => item[:quantity] - self.quantity)
		item.update!(:quantity_on_loan => item[:quantity_on_loan] + self.quantity)
	end

	def status_change_to_satisfied
		item = self.request_item.item

		item.update!(:quantity => item[:quantity] + self.quantity)	
		item.update!(:quantity_on_loan => item[:quantity_on_loan] - self.quantity)
	end

	def status_change_to_failed
		req_item = self.request_item
	
		req_item.update!(:quantity_loan => req_item[:quantity_loan] + self.quantity)
	end

end
