class UserLog < ApplicationRecord
	include Loggable, Authorable 	
    
	# Associations
	#belongs_to :logs

	enum action: {
		created: 0,
		deactivated: 1,
		privilege_updated: 2
	}

	enum old_privilege: {
		student: 0,
		manager: 1,
		admin: 2
	}, _prefix: :old_priv

	enum new_privilege: {
		student: 0,
		manager: 1,
		admin: 2
	}, _prefix: :new_priv


	# VALIDATION
	validates :action, :inclusion => { :in => USER_LOGGED_ACTIONS }
	validates :old_privilege, :inclusion => { :in => PRIVILEGE_OPTIONS }
	validates :new_privilege, :inclusion => { :in => PRIVILEGE_OPTIONS }

end
