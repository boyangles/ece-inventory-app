class ItemLog < ApplicationRecord
	include Loggable

	enum action: {
		created: 0,
		deleted: 1,
		acquired_quantity: 2,
		destroyed_quantity: 3,
		admin_corr_quantity: 4,
		desc_updated: 5
	}

	validates :action, :inclusion => { :in => USER_LOGGED_ACTIONS }

end
