require 'rails_helper'

describe Api::V1::TagsController do
  describe "GET #index" do
    it "unauthorized user has no access" do
      get :index
      response = expect_401_unauthorized
      expect(response[:errors]).to include "Not authenticated"
    end

    it "authorized user has full access" do
      create_and_authenticate_user(:user_student)
      get :index
      should respond_with 200
    end

    it "authorized user with query" do
      create_and_authenticate_user(:user_admin)
      get :index, { name: 'Resistor' }
      should respond_with 200
    end
  end

  describe "GET #show" do
    it "unauthorized user has no access" do
      tag = FactoryGirl.create :tag
      get :show, id: tag.id
      response = expect_401_unauthorized
      expect(response[:errors]).to include "Not authenticated"
    end

    it "authorized user has access" do
      create_and_authenticate_user(:user_student)
      tag = FactoryGirl.create :tag
      get :show, id: tag.id

      tag_response = json_response
      expect(tag_response[:name]).to eql tag.name
      should respond_with 200
    end

    it "unknown tag" do
      create_and_authenticate_user(:user_admin)
      get :show, id: -1

      response = expect_404_not_found
      expect(response[:errors]).to include "Tag not found!"
    end
  end

  describe "POST #create" do
    # Successful Create
    context "when create succesfully" do
      before(:each) do
        create_and_authenticate_user(:user_admin)
        @tag_attributes = FactoryGirl.attributes_for :tag
        post :create, {tag: @tag_attributes}
      end

      it "renders json representation for tag just created" do
        tag_response = json_response
        expect(tag_response[:name]).to eql @tag_attributes[:name]
      end

      it { should respond_with 201 }
    end

    # Unsuccessful Create
    context "when unsuccesful creation" do
      before(:each) do
        create_and_authenticate_user(:user_admin)
        @tag1 = FactoryGirl.create :tag
        @tag_attributes = FactoryGirl.attributes_for :tag

        @tag_attributes[:name] = @tag1[:name]
        post :create, {tag: @tag_attributes}
      end

      it "renders JSON error" do
        tag_response = json_response
        expect(tag_response).to have_key(:errors)
      end

      it { should respond_with 422 }
    end
  end

  describe "PUT/PATCH #update" do
    # Successful Update
    context "when successfully update" do
      before(:each) do
        create_and_authenticate_user(:user_admin)
        @tag = FactoryGirl.create :tag
        patch :update, {id: @tag.id,
                        tag: {name: @tag.name}}
      end

      it "renders json representation of updated request" do
        tag_response = json_response
        expect(tag_response[:name]).to eql @tag.name
      end

      it { should respond_with 200 }
    end

    # Unsuccessful Update
    context "when unsuccessful in updating" do
      before(:each) do
        create_and_authenticate_user(:user_admin)
        @tag1 = FactoryGirl.create :tag
        @tag2 = FactoryGirl.create :tag

        patch :update, {id: @tag2.id,
                        tag: {name: @tag1.name}}
      end

      it "renders error from JSON" do
        tag_response = json_response
        expect(tag_response).to have_key(:errors)
      end

      it { should respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      create_and_authenticate_user(:user_admin)
      @tag = FactoryGirl.create :tag
      delete :destroy, {id: @tag.id}
    end

    it { should respond_with 204 }
  end
end