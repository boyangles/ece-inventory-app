module Loggable
	extend ActiveSupport::Concern

	# CONSTANTS:
	LOG_TYPES = %w(user item request)
	USER_LOGGED_ACTIONS = %w(created deleted privilege_updated)
	ITEM_LOGGED_ACTIONS = %w(acquired destroyed admin_correction desc_updated)
	REQUEST_LOGGED_ACTIONS = %w(placed_order cancelled approved denied)
	

	module ClassMethods

	end

end
