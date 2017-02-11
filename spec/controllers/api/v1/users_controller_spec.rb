require 'rails_helper'

describe Api::V1::UsersController do
  before(:each) { request.headers['Accept'] = "application/vnd.spicysoftwareinventory.v1" }

  describe "GET #show" do
    before(:each) do
      @user = FactoryGirl.create :user
      get :show, id: @user.id, format: :json
    end

    it "returns info about a reporter on a hash" do
      user_response = JSON.parse(response.body, symbolize_names: true)
      expect(user_response[:email]).to eql @user.email
    end

    it { should respond_with 200 }
  end

  describe "POST #create" do
    # Successful user creation
    context "when is successfully created" do
      before(:each) do
        @user_attributes = FactoryGirl.attributes_for :user
        @user_attributes[:email] = @user_attributes[:email].downcase
        post :create, { user: @user_attributes }, format: :json
      end

      it "renders the json representation for the user record just created" do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:email]).to eql @user_attributes[:email]
      end

      it { should respond_with 201 }
    end

    # Unsucessful creation
    context "when is not created" do
      before(:each) do
        @invalid_user_attributes = { password: "password",
                                     password_confirmation: "password" }
        post :create, { user: @invalid_user_attributes }, format: :json
      end

      it "renders JSON error" do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response).to have_key(:errors)
      end

      it "renders json errors on why user could not be created" do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:errors][:email]).to include "can't be blank"
      end

      it { should respond_with 422 }
    end
  end

  describe "PUT/PATCH #update" do
    context "when is successfully updated" do
      before(:each) do
        @user = FactoryGirl.create :user
        patch :update, { id: @user.id,
                         user: { email: "newmailexample@duke.edu" } }, format: :json
      end

      it "renders json representation for updated user" do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:email]).to eql "newmailexample@duke.edu"
      end

      it { should respond_with 200 }
    end

    context "when is not created" do
      before(:each) do
        @user = FactoryGirl.create :user
        patch :update, { id: @user.id,
                         user: { email: "bademail.com" } }, format: :json
      end

      it "renders error from JSON" do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response).to have_key(:errors)
      end

      it "renders the json errors on why the user couldn't be created" do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:errors][:email]).to include "is invalid"
      end

      it { should respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      delete :destroy, { id: @user.id }, format: :json
    end

    it { should respond_with 204 }
  end
end
