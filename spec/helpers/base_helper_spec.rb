require 'rails_helper'

def create_and_authenticate_admin_user
  @admin = FactoryGirl.create :user_admin
  api_authorization_header @admin[:auth_token]
end

def login_user(user)
  visit login_url
  fill_in 'Username', :with => user.username
  fill_in 'Password', :with => user.password
  click_button 'Log in'
end