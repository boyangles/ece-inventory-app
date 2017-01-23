class User < ApplicationRecord

  before_validation {
    self.username = username.downcase
    self.email = email.downcase
    self.privilege = privilege.downcase
    self.status = status.downcase
  }

  before_save { 
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
  validates :password, presence: true, length: { minimum: 6 }
  validates :status, presence: true

  # Validation checks for checkboxes that will be created to only allow certain input
  validates_inclusion_of :status, :in => %w[approved waiting], :message => "Status must either be approved or waiting"
  validates_inclusion_of :privilege, :in => %w[admin student ta], :message => "Privilege must be admin, ta, or student"


  # some useful validation types we might use later on
  #validates_exclusion_of :username, :in => %w[bruh]
  #validates_format_of :privilege, :with => /\A(admin)\Z/


  #Adds functionality to save a securely hashed password_digest attribute to the database
  #Adds a pair of virtual attributes (password and password_confirmation), including presence validations upon object creation and a validation requiring that they match.
  #Adds an authenticate method that returns the user when the password is correct and false otherwise
  has_secure_password
end
