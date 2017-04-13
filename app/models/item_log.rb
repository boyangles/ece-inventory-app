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
		disbursed_from_loan: 8
	}

	validates :action, :inclusion => { :in => ITEM_LOGGED_ACTIONS }

end
