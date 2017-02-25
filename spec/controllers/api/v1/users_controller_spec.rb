require 'rails_helper'
#require 'helpers/base_helper_spec'

describe Api::V1::UsersController do
  describe "GET #show" do
    before(:each) do
      create_and_authenticate_admin_user
      get :show, id: @admin.id
    end

    it "returns info about a reporter on a hash" do
      user_response = json_response
      expect(user_response[:email]).to eql @admin.email
    end

    it { should respond_with 200 }
  end

  describe "POST #create" do
    # Successful user creation
    context "when is successfully created" do
      before(:each) do
        create_and_authenticate_admin_user
        @user_attributes = FactoryGirl.attributes_for :admin
        @user_attributes[:email] = @user_attributes[:email].downcase

        post :create, @user_attributes
      end

      it "renders the json representation for the user record just created" do
        user_response = json_response
        expect(user_response[:email]).to eql @user_attributes[:email]
      end

      it { should respond_with 201 }
    end

    # Unsucessful creation
    context "when is not created" do
      before(:each) do
        create_and_authenticate_admin_user
        @invalid_user_attributes = { password: "password",
                                     password_confirmation: "invalid_password" }
        post :create, @invalid_user_attributes
      end

      it "renders JSON error" do
        user_response = json_response
        expect(user_response).to have_key(:errors)
      end

      it "renders json errors on why user could not be created" do
        user_response = json_response
        expect(user_response[:errors][:password_confirmation]).to include "doesn't match Password"
      end

      it { should respond_with 422 }
    end
  end

  describe "PUT/PATCH #update" do
    context "when is successfully updated" do
      before(:each) do
        create_and_authenticate_admin_user
        patch :update, { id: @admin.id,
                        email: "newmailexample@duke.edu" }
      end

      it "renders json representation for updated user" do
        user_response = json_response
        expect(user_response[:email]).to eql "newmailexample@duke.edu"
      end

      it { should respond_with 200 }
    end

    context "when is not created as email is empty" do
      before(:each) do
        create_and_authenticate_admin_user
        patch :update, { id: @admin.id,
                        email: "" }
      end

      # TODO: Change when validation of email is finalized
      xit "renders error from JSON" do
        user_response = json_response
        expect(user_response).to have_key(:errors)
      end

      xit "renders the json errors on why the user couldn't be created" do
        user_response = json_response
        expect(user_response[:errors][:email]).to include "can't be blank"
      end

      xit { should respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      create_and_authenticate_admin_user
      delete :destroy, { id: @admin.id }
    end

    it { should respond_with 204 }
  end

  private
  def create_and_authenticate_admin_user
    @admin = FactoryGirl.create :admin
    api_authorization_header @admin[:auth_token]
  end
end
