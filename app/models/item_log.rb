class ItemLog < ApplicationRecord
	include Loggable

	enum action: {
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

	validates :action, :inclusion => { :in => ITEM_LOGGED_ACTIONS }

end
