class User < ApplicationRecord
  before_save { self.username = username.downcase }

  validates :username, presence: true, length: { maximum: 50 },
                       uniqueness: { case_sensitive: false }
  validates :privilege, presence: true
  validates :password, presence: true
end
