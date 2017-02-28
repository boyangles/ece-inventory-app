require 'rails_helper'

describe Api::V1::RequestsController do
  skip "Skipped for API mods" do
    describe "GET #show" do
      before(:each) do
        @req = FactoryGirl.create :request
        @user = create_and_authenticate_user(:user_admin)
        get :show, id: @req.id
      end

      it "returns info about a reporter on a hash" do
        req_response = json_response
        expect(req_response[:user_id]).to eql @req.user_id
      end

      it { should respond_with 200 }
    end

    describe "POST #create" do
      context "when a request is successfully created with valid user and item ids" do
        before(:each) do
          req_attribute_creation
          @req_attributes[:user_id] = @sample_user[:id]
          post :create, @req_attributes
        end

        it "renders the json representation for the request record just created" do
          req_response = json_response
          expect(req_response[:user_id]).to eql @req_attributes[:user_id]
        end

        it { should respond_with 201 }
      end

      context "when a request is not created because of invalid user and item ids" do
        before(:each) do
          req_attribute_creation
          @req_attributes[:user_id] = -1
          post :create, {request: @req_attributes}
        end

        it "renders JSON error" do
          req_response = json_response
          expect(req_response).to have_key(:errors)
        end

        it { should respond_with 422 }
      end
    end
  end

  describe "PUT/PATCH #update" do
    skip "Skipped for API mods" do

      context "when a request is successfully updated with valid request and user" do
        before(:each) do
          @req = FactoryGirl.create :request
          @user = create_and_authenticate_user(:user_admin)
          patch :update, { id: @req.id,
                           reason: "Updated because I can." }
        end

        it "renders json representation for updated request" do
          req_response = json_response
          expect(req_response[:reason]).to eql "Updated because I can."
        end

        it { should respond_with 200 }
      end

      context "when not successful in updating a request because of invalid user id" do
        before(:each) do
          @req = FactoryGirl.create :request
          @user = create_and_authenticate_user(:user_admin)
          patch :update, { id: @req.id,
                           user_id: -1 }
        end

        it "renders error from JSON" do
          req_response = json_response
          expect(req_response).to have_key(:errors)
        end

        it { should respond_with 422 }
      end
    end

    describe "DELETE #destroy" do
      skip "skip fuck" do
        before(:each) do
          @req = FactoryGirl.create :request
          @user = create_and_authenticate_user(:user_admin)
          delete :destroy, { id: @req.id }
        end

        it { should respond_with 204 }
      end
    end

    private
    def req_attribute_creation
      @sample_user = FactoryGirl.create :user_admin
      @sample_item = FactoryGirl.create :item
      api_authorization_header @sample_user[:auth_token]

      @req_attributes = FactoryGirl.attributes_for :request
    end
  end
end
