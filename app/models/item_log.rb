class ItemLog < ApplicationRecord
	include Loggable

	enum action: {
		acquired_destroyed_quantity: 0,
		admin_corr_quantity: 1,
		disbursed: 2,
		created: 3,
		deleted: 4,
		desc_updated: 5
	}

	validates :action, :inclusion => { :in => ITEM_LOGGED_ACTIONS }

end
