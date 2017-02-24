class Log < ApplicationRecord
  include Filterable, Subscribable

  default_scope -> { order(created_at: :desc) }

	LOG_TYPES = %w(user item request)
	enum log_type: {
		user: 0,
		item: 1,
		request: 2		
	}#, prefix: :type 
  
  scope :user_id,       -> (user_id)      { where user_id: user_id }
	
	validates :log_type, :inclusion => { :in => LOG_TYPES }
  
	# Methods:
end
