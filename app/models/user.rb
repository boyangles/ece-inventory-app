class User < ApplicationRecord

  PRIVILEGE_OPTIONS = %w(student manager admin)
  STATUS_OPTIONS = %w(waiting approved)

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
    waiting: 0,
    approved: 1
  }, _prefix: :status

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
    
		# create a log and user log!
		@log = Log.new(:user_id => self.curr_user, :log_type => "user")
		@log.save!
		@userlog = UserLog.new(:log_id => @log.id, :user_id => self.id, :action => "creation", :old_privilege => 0, :new_privilege => self.privilege)
		@userlog.save!
  }

	after_destroy {
		# TODO - log now has to ???
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

  def generate_authentication_token!
    begin
      self.auth_token = Devise.friendly_token
    end while self.class.exists?(auth_token: auth_token)
  end

  def create_new_cart(id)
    @cart = Request.new(:status => :cart, :user_id => id, :reason => 'TBD')
    @cart.save!
  end
end
