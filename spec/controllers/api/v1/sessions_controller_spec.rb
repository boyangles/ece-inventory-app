require 'rails_helper'
include SessionsHelper

describe Api::V1::SessionsController do
  describe 'POST #create' do
    before(:each) do
      @user = FactoryGirl.create :user
    end

    context 'when credentials are correct' do
      before(:each) do
        @user[:status] = 'approved'
        @user.save

        post_credentials(@user[:email], 'password')
      end

      it 'returns the user record corresponding to the given credentials' do
        @user.reload
        expect(json_response[:auth_token]).to eql @user.auth_token
      end

      it { should respond_with 200 }
    end

    context 'when password credentials are incorrect' do
      before(:each) do
        @user[:status] = 'approved'
        @user.save

        post_credentials(@user[:email], 'invalid_password')
      end

      it 'returns a json with error' do
        expect(json_response[:errors]).to eql 'Invalid email or password'
      end

      it { should respond_with 422 }
    end

    context 'when user is not approved' do
      before(:each) do
        @user[:status] = 'waiting'
        @user.save

        post_credentials(@user[:email], 'password')
      end

      it 'returns a json with error indicating status' do
        expect(json_response[:errors]).to eql 'Your account has not been approved by an administrator'
      end

      it { should respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      log_in @user
      delete :destroy, id: @user.auth_token
    end

    it { should respond_with 204 }
  end

  private
  def post_credentials(input_email, input_password)
    credentials = { :email => input_email, :password => input_password }
    post :create, { :sess => credentials }
  end
end