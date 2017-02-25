require 'rails_helper'

describe Api::V1::TagsController do
  describe "GET #show" do
    before(:each) do
      create_and_authenticate_admin_user
      @tag = FactoryGirl.create :tag
      get :show, id: @tag.id
    end

    it "returns info about a reporter on a hash" do
      tag_response = json_response
      expect(tag_response[:name]).to eql @tag.name
    end

    it { should respond_with 200 }
  end

  describe "POST #create" do
    # Successful Create
    context "when create succesfully" do
      before(:each) do
        create_and_authenticate_admin_user
        @tag_attributes = FactoryGirl.attributes_for :tag
        post :create, @tag_attributes
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
        create_and_authenticate_admin_user
        @tag1 = FactoryGirl.create :tag
        @tag_attributes = FactoryGirl.attributes_for :tag

        @tag_attributes[:name] = @tag1[:name]
        post :create, @tag_attributes
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
        create_and_authenticate_admin_user
        @tag = FactoryGirl.create :tag
        patch :update, { id: @tag.id,
                         name: @tag.name }
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
        create_and_authenticate_admin_user
        @tag1 = FactoryGirl.create :tag
        @tag2 = FactoryGirl.create :tag

        patch :update, { id: @tag2.id,
                          name: @tag1.name }
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
      create_and_authenticate_admin_user
      @tag = FactoryGirl.create :tag
      delete :destroy, {id: @tag.id }
    end

    it { should respond_with 204 }
  end

  private
  def create_and_authenticate_admin_user
    @admin = FactoryGirl.create :admin
    api_authorization_header @admin[:auth_token]
  end
end