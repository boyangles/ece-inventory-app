require 'rails_helper'

describe Api::V1::RequestsController do
  describe "GET #show" do
    before(:each) do
      @req = FactoryGirl.create :request
      get :show, id: @req.id
    end

    it "returns info about a reporter on a hash" do
      req_response = json_response
      expect(req_response[:user_id]).to eql @req.user_id
      expect(req_response[:item_id]).to eql @req.item_id
    end

    it { should respond_with 200 }
  end

  describe "POST #create" do
    context "when is successfully created" do
      before(:each) do
        req_attribute_creation

        @req_attributes[:user_id] = @sample_user[:id]
        @req_attributes[:item_id] = @sample_item[:id]
        post :create, {request: @req_attributes}
      end

      it "renders the json representation for the request record just created" do
        req_response = json_response
        expect(req_response[:user_id]).to eql @req_attributes[:user_id]
        expect(req_response[:item_id]).to eql @req_attributes[:item_id]
      end

      it { should respond_with 201 }
    end

    context "when is not created" do
      before(:each) do
        req_attribute_creation

        @req_attributes[:user_id] = @sample_user[:id] + 1
        @req_attributes[:item_id] = @sample_item[:id] + 1

        post :create, {request: @req_attributes}
      end

      it "renders JSON error" do
        req_response = json_response
        expect(req_response).to have_key(:errors)
      end

      it { should respond_with 422 }
    end
  end

  describe "PUT/PATCH #update" do
    context "when is successfully updated" do
      before(:each) do
        @req = FactoryGirl.create :request
        patch :update, { id: @req.id,
                         request: { reason: "Because I can." } }
      end

      it "renders json representation for updated request" do
        req_response = json_response
        expect(req_response[:reason]).to eql "Because I can."
      end

      it { should respond_with 200 }
    end

    context "when not successful in updating" do
      before(:each) do
        @req = FactoryGirl.create :request
        patch :update, { id: @req.id,
                         request: { item_id: @req.item_id + 1 } }
      end

      it "renders error from JSON" do
        req_response = json_response
        expect(req_response).to have_key(:errors)
      end

      it { should respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @req = FactoryGirl.create :request
      delete :destroy, { id: @req.id }
    end

    it { should respond_with 204 }
  end

  private
  def req_attribute_creation
    @sample_user = FactoryGirl.create :user
    @sample_item = FactoryGirl.create :item

    @req_attributes = FactoryGirl.attributes_for :request
  end
end
