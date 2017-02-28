require 'rails_helper'
include SessionsHelper

describe Api::V1::SessionsController do
  describe 'POST #create' do
    before(:each) do
      @admin = create_and_authenticate_user(:user_admin)
    end

    context 'when credentials are correct' do
      before(:each) do
        post_credentials(@admin.email, @admin.password)
      end

      it 'returns the user record corresponding to the given credentials' do
        @admin.reload
        expect(json_response[:authorization]).to eql @admin.auth_token
      end

      it { should respond_with 200 }
    end

    context 'when password credentials are incorrect' do
      before(:each) do
        post_credentials(@admin.email, "")
      end

      it 'returns a json with error' do
        expect(json_response[:errors]).to eql 'Invalid username or password'
      end

      it { should respond_with 422 }
    end

    # TODO: Skipping because user status is hardcoded in sessions controller
    context 'when user is not approved' do
      before(:each) do
        @admin[:status] = 'deactivated'
        @admin.save

        post_credentials(@admin.email, @admin.password)
      end

      it 'returns a json with error indicating status' do
        expect(json_response[:errors]).to eql 'Your account has not been approved by an administrator'
      end

      it { should respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    it "user doesn't exist" do
      delete :destroy, id: 'invalid_auth_token'
      response = expect_422_unprocessable_entity
      expect(response[:errors]).to include "Invalid authorization token"
    end

    it "user exists" do
      user = FactoryGirl.create :user_admin
      delete :destroy, id: user.auth_token
      should respond_with 204
    end
  end

  private
  def post_credentials(input_email, input_password)
    credentials = { :email => input_email, :password => input_password }
    post :create, credentials
  end
end