class UserLog < ApplicationRecord
	
	USER_ACTION_OPTIONS = %w(creation deletion privilege_change)
	PRIVILEGE_OPTIONS = %w(student manager admin)
    
	# Associations
	#belongs_to :logs

	enum action: {
		creation: 0,
		deletion: 1,
		privilege_change: 2
	}, _prefix: :action

	enum old_privilege: {
		student: 0,
		manager: 1,
		admin: 2
	}, _prefix: :old_privilege

	enum new_privilege: {
		student: 0,
		manager: 1,
		admin: 2
	}, _prefix: :new_privilege


	# VALIDATION
	validates :action, :inclusion => { :in => USER_ACTION_OPTIONS }
	validates :old_privilege, :inclusion => { :in => PRIVILEGE_OPTIONS }
	validates :new_privilege, :inclusion => { :in => PRIVILEGE_OPTIONS }

end
