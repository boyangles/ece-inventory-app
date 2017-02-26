require 'spec_helper'

class Authentication
  include Authenticable
end

describe Authenticable do
  let(:authentication) { Authentication.new }
  subject { authentication }

  describe "#current_user_by_auth" do
    before do
      @user = FactoryGirl.create :user
      request.headers['Authorization'] = @user.auth_token
      allow(subject).to receive(:request).and_return(request)
    end

    it 'returns the user from the authorization header' do
      expect(authentication.current_user_by_auth.auth_token).to eql @user.auth_token
    end
  end

  describe "#authenticate_with_token" do
    before do
      @user = FactoryGirl.create :user
      allow(subject).to receive(:current_user_by_auth).and_return(nil)
      allow(response).to receive(:response_code).and_return(401)
      allow(response).to receive(:body).and_return({'errors' => 'Not authenticated'}.to_json)
      allow(subject).to receive(:response).and_return(response)
    end

    it "render a json error message" do
      expect(json_response[:errors]).to eql 'Not authenticated'
    end

    it { expect(subject).to  respond_with 401 }
  end

  describe "#user_signed_in?" do
    context "when there is a user on 'session'" do
      before do
        @user = FactoryGirl.create :user
        allow(subject).to receive(:current_user_by_auth).and_return(@user)
      end

      it { expect(subject).to  be_user_signed_in }
    end

    context "when there is no user on 'session'" do
      before do
        @user = FactoryGirl.create :user
        allow(subject).to receive(:current_user_by_auth).and_return(nil)
      end

      it { expect(subject).not_to  be_user_signed_in }
    end
  end
end