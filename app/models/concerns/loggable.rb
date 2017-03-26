module Loggable
	extend ActiveSupport::Concern

	# CONSTANTS:
	LOG_TYPES = %w(user item request)
	USER_LOGGED_ACTIONS = %w(created deactivated privilege_updated)
	ITEM_LOGGED_ACTIONS = %w(created deleted acquired_or_destroyed_quantity administrative_correction desc_updated disbursed) # may have to add disbursement and in future, return -> add also to item_log model enums
	REQUEST_LOGGED_ACTIONS = %w(placed cancelled approved denied)
	

	module ClassMethods

	end

end
