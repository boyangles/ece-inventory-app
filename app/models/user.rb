class User < ApplicationRecord
  include Filterable

  PRIVILEGE_OPTIONS = %w(student manager admin)
  STATUS_OPTIONS = %w(deactivated approved)
  DUKE_EMAIL_REGEX = /\A[\w+\-.]+@duke\.edu\z/i

  # Relation with Requests
  has_many :requests, dependent: :destroy

  # Relation with Logs - not necessarily one-to-many
  # has_many :logs

  # Relation with User_Logs
  has_many :user_logs

  enum privilege: {
    student: 0,
    manager: 1,
    admin: 2
  }, _prefix: :privilege

  enum status: {
    deactivated: 0,
    approved: 1
  }, _prefix: :status

  # Filterable params:
  scope :email,     ->    (email)     { where email: email }
  scope :status,    ->    (status)    { where status: status }
  scope :privilege, ->    (privilege) { where privilege: privilege }


  before_validation {
    # Only downcase if the fields are there
    # TODO: Figure out what to do with emails for local accounts. can't have blank as two local accounts cannot be created then.
    self.username = (username.to_s == '') ? username : username.downcase
    self.email = (email.to_s == '') ? "#{username.to_s}@example.com" : email.downcase
  }

  # Creates the confirmation token before a user is created
  before_create {
    confirmation_token
    generate_authentication_token!
  }

  after_create {
    create_new_cart(self.id)
		create_log("created", 0, self.privilege)
	}

	after_update {
		log_on_privilege_change()
		when_deactivated()
	}
	
  validates :username, presence: true, length: { maximum: 50 },
                       uniqueness: { case_sensitive: false }
  validates :email, presence: true, length: { maximum: 255 },
                       uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }, :if => :password
  validates :privilege, :inclusion => { :in => PRIVILEGE_OPTIONS }
  validates :status, :inclusion => { :in => STATUS_OPTIONS }
  validates :auth_token, uniqueness: true

	# scope that gives us current_user
	#scope :curr_user, lambda { |user| 
	#	where("user.id = ?", user.id)
	#}
	attr_accessor :curr_user

  # Returns the hash digest for a given string, used in fixtures for testing
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end


  #Adds functionality to save a securely hashed password_digest attribute to the database
  #Adds a pair of virtual attributes (password and password_confirmation), including presence validations upon object creation and a validation requiring that they match.
  #Adds an authenticate method that returns the user when the password is correct and false otherwise
  has_secure_password

  # This method confirms a user has confirmed their email. Generates a random string to assign to the token, which identifies
  # which user to confirm
  def confirmation_token
    if self.confirm_token.blank?
      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end

  def deactivate
    self.status = 'deactivated'
    self.save!
  end

  def generate_authentication_token!
    begin
      self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token: auth_token)
  end

  def create_new_cart(id)
    @cart = Request.new(:status => :cart, :user_id => id, :reason => 'TBD')
    @cart.save!
  end

	def when_deactivated()
		if self.status_was == "approved" && self.status == "deactivated"
			create_log("deactivated", self.privilege, self.privilege)

			# change all user's requests to cancelled
			self.requests.each do |req|
				if req.outstanding?
					req.update("status": "cancelled")
				end
			end		 
		end
	end

	def log_on_privilege_change() 
		old_privilege = self.privilege_was
		new_privilege = self.privilege

		if old_privilege != new_privilege
			create_log("privilege_updated", old_privilege, new_privilege)
		end
	end

	def create_log(action, old_priv, new_priv)
		if self.curr_user.nil?
			curr = nil
		else
			curr = self.curr_user.id
		end

		log = Log.new(:user_id => curr, :log_type => "user")
		log.save!
		userlog = UserLog.new(:log_id => log.id, :user_id => self.id, :action => action, :old_privilege => old_priv, :new_privilege => new_priv)
		userlog.save!

  end


  ## Class Methods
  def self.filter_by_search(search_input)
    where("username ILIKE ?", "%#{search_input}%")
  end

  def self.isDukeEmail?(email_address)
    return email_address.match(DUKE_EMAIL_REGEX)
  end
end
