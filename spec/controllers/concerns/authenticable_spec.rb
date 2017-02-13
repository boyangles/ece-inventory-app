require 'spec_helper'

class Authentication
  include Authenticable
end

describe Authenticable do
  let(:authentication) { Authentication.new }
  subject { authentication }

  describe '#current_user_by_auth' do
    before do
      @user = FactoryGirl.create :user
      request.headers['Authorization'] = @user.auth_token
      authentication.stub(:request).and_return(request)
    end
    it 'returns the user from the authorization header' do
      expect(authentication.current_user_by_auth.auth_token).to eql @user.auth_token
    end
  end
end