require 'rails_helper'
include SessionsHelper

describe Api::V1::SessionsController do
  describe 'POST #create' do
    before(:each) do
      create_and_authenticate_admin_user
    end

    context 'when credentials are correct' do
      before(:each) do
        post_credentials(@user.username, @user.password)
      end

      it 'returns the user record corresponding to the given credentials' do
        @user.reload
        expect(json_response[:auth_token]).to eql @user.auth_token
      end

      it { should respond_with 200 }
    end

    context 'when password credentials are incorrect' do
      before(:each) do
        post_credentials(@user.username, "")
      end

      it 'returns a json with error' do
        expect(json_response[:errors]).to eql 'Invalid username or password'
      end

      it { should respond_with 422 }
    end

    # TODO: Skipping because user status is hardcoded in sessions controller
    context 'when user is not approved' do
      before(:each) do
        @user[:status] = 'waiting'
        @user.save

        post_credentials(@user.username, @user.password)
      end

      xit 'returns a json with error indicating status' do
        expect(json_response[:errors]).to eql 'Your account has not been approved by an administrator'
      end

      xit { should respond_with 422 }
    end
  end

  # TODO: @Austin  Not sure what delete is supposed to do in sessions controller api
  # describe "DELETE #destroy" do
  #   before(:each) do
  #     create_and_authenticate_admin_user
  #     log_in @user
  #     delete :destroy, id: @user.auth_token
  #   end
  #
  #   it { should respond_with 204 }
  # end

  private
  def post_credentials(input_username, input_password)
    credentials = { :username => input_username, :password => input_password }
    post :create, credentials
  end

  private
  def create_and_authenticate_admin_user
    @user = FactoryGirl.create :user
    api_authorization_header @user[:auth_token]
  end
end