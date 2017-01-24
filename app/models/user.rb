class User < ApplicationRecord

  before_validation {
    self.username = username.downcase
    self.email = email.downcase
    self.privilege = privilege.downcase
    self.status = status.downcase
  }

  # Modified to only allow duke emails
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-\.]*duke\.edu\z/i

  validates :username, presence: true, length: { maximum: 50 },
                       uniqueness: { case_sensitive: false }
  validates :email, presence: true, length: { maximum: 255 },
                       format: { with: VALID_EMAIL_REGEX },
                       uniqueness: { case_sensitive: false }
  validates :privilege, presence: true
  # Allowing for nil is okay because has_secure_password has another nil validation
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates :status, presence: true

  # Validation checks for checkboxes that will be created to only allow certain input
  validates_inclusion_of :status, :in => %w[approved waiting], :message => "Status must either be approved or waiting"
  validates_inclusion_of :privilege, :in => %w[admin student ta], :message => "Privilege must be admin, ta, or student"


  # some useful validation types we might use later on
  #validates_exclusion_of :username, :in => %w[bruh]
  #validates_format_of :privilege, :with => /\A(admin)\Z/

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
end
