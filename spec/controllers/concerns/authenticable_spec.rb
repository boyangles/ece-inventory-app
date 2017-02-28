require 'spec_helper'

class Authentication
  include Authenticable
end

describe Authenticable do
  let(:authentication) { Authentication.new }
  subject { authentication }

  describe "#current_user_by_auth" do
    before do
      @admin = FactoryGirl.create :user_admin
      request.headers['Authorization'] = @admin.auth_token
      authentication.stub(:request).and_return(request)
    end

    it 'returns the user from the authorization header' do
      expect(authentication.current_user_by_auth.auth_token).to eql @admin.auth_token
    end
  end

  describe "#authenticate_with_token" do
    before do
      @admin = FactoryGirl.create :user_admin
      authentication.stub(:current_user_by_auth).and_return(nil)
      response.stub(:response_code).and_return(401)
      response.stub(:body).and_return({'errors' => 'Not authenticated'}.to_json)
      authentication.stub(:response).and_return(response)
    end

    it "render a json error message" do
      expect(json_response[:errors]).to eql 'Not authenticated'
    end

    it { should respond_with 401 }
  end

  describe "#user_signed_in?" do
    context "when there is a user on 'session'" do
      before do
        @admin = FactoryGirl.create :user_admin
        authentication.stub(:current_user_by_auth).and_return(@admin)
      end

      it { should be_user_signed_in }
    end

    context "when there is no user on 'session'" do
      before do
        @admin = FactoryGirl.create :user_admin
        authentication.stub(:current_user_by_auth).and_return(nil)
      end

      it { should_not be_user_signed_in }
    end
  end
end