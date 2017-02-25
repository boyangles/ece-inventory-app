class ItemLog < ApplicationRecord
	include Loggable

	enum action: {
		created: 0,
		deleted: 1,
		acquired_destroyed_quantity: 2,
		admin_corr_quantity: 3,
		desc_updated: 4
	}

	validates :action, :inclusion => { :in => USER_LOGGED_ACTIONS }

end
