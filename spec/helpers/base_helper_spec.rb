require 'rails_helper'

def create_and_authenticate_admin_user
  @admin = FactoryGirl.create :admin
  api_authorization_header @admin[:auth_token]
end