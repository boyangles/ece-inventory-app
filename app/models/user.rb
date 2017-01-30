class User < ApplicationRecord
  enum privilege: {
    student: 0,
    ta: 1,
    admin: 2
  }, _prefix: :privilege

  enum status: {
    waiting: 0,
    approved: 1
  }, _prefix: :status

  before_validation {
    self.username = username.downcase
    self.email = email.downcase
  }

  # Creates the confirmation token before a user is created
  before_create {
    confirmation_token
  }

  # Modified to only allow duke emails
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-\.]*duke\.edu\z/i

  validates :username, presence: true, length: { maximum: 50 },
                       uniqueness: { case_sensitive: false }
  validates :email, presence: true, length: { maximum: 255 },
                       format: { with: VALID_EMAIL_REGEX },
                       uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }


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

  def email_activate
    self.email_confirmed = true
    self.confirm_token = nil
    save!(:validate => false)
  end

end
