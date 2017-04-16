module Loggable
	extend ActiveSupport::Concern

	# CONSTANTS:
	LOG_TYPES = %w(user item request)
	USER_LOGGED_ACTIONS = %w(created deactivated privilege_updated)
	ITEM_LOGGED_ACTIONS = %w(created deleted description_updated
		acquired_or_destroyed_quantity administrative_correction 
		disbursed loaned returned disbursed_from_loan
		backfill_requested backfill_request_approved backfill_request_denied
		backfill_request_satisfied backfill_request_failed)
	REQUEST_LOGGED_ACTIONS = %w(placed cancelled approved denied)
	

	module ClassMethods

	end

end
