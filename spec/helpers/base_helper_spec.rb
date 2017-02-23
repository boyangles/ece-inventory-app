require 'rails_helper'

def create_and_authenticate_admin_user
  @user = FactoryGirl.create :user
  api_authorization_header @user[:auth_token]
end