class RequestLog < ApplicationRecord
	include Loggable

	enum action: {
		placed: 0,
		cancelled: 1,
		approved: 2,
		denied: 3
	}
		
	#VALIDATION
	validates :action, :inclusion => { :in => REQUEST_LOGGED_ACTIONS }

end
