require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /users" do
    skip "this is stoopid" do
      it "works! (now write some real specs)" do
        get users_path
        expect(response).to have_http_status(200)
      end
    end
  end
end
