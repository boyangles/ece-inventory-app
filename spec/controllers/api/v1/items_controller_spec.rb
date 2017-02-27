require 'rails_helper'

describe Api::V1::ItemsController do
  # describe "GET #show" do
  #   before(:each) do
  #     @user = create_and_authenticate_user(:user_admin)
  #     @item = FactoryGirl.create :item
  #     get :show, id: @item.id
  #   end
  #
  #   it "returns info about a reporter on a hash" do
  #     item_response = json_response
  #     expect(item_response[:unique_name]).to eql @item.unique_name
  #   end
  #
  #   it { should respond_with 200 }
  # end
  #
  # describe "POST #create" do
  #   # Successful item creation
  #   context "when is successfully created" do
  #     before(:each) do
  #       @user = create_and_authenticate_user(:user_admin)
  #       @item_attributes = FactoryGirl.attributes_for :item
  #       post :create, @item_attributes
  #     end
  #
  #     it "renders the json representation for the item record just created" do
  #       item_response = json_response
  #       expect(item_response[:unique_name]).to eql @item_attributes[:unique_name]
  #     end
  #
  #     it { should respond_with 201 }
  #   end
  #
  #   # Unsuccessful item creation
  #   context "when is not successfully created" do
  #     before(:each) do
  #       @user = create_and_authenticate_user(:user_admin)
  #       @item1 = FactoryGirl.create :item
  #       @item2_attributes = FactoryGirl.attributes_for :item
  #       @item2_attributes[:unique_name] = @item1[:unique_name]
  #
  #       post :create, @item2_attributes
  #     end
  #
  #     it "renders JSON error" do
  #       item_response = json_response
  #       expect(item_response).to have_key(:errors)
  #     end
  #
  #     it { should respond_with 422 }
  #   end
  # end
  #
  # describe "PUT/PATCH #update" do
  #   # Successful Update
  #   context "when is successfully updated" do
  #     before(:each) do
  #       @user = create_and_authenticate_user(:user_admin)
  #       @item = FactoryGirl.create :item
  #       patch :update, { id: @item.id,
  #                        description: "Sample description" }
  #     end
  #
  #     it "renders json representation for updated item" do
  #       item_response = json_response
  #       expect(item_response[:description]).to eql "Sample description"
  #     end
  #
  #     it { should respond_with 200 }
  #   end
  #
  #   # Unsuccessful Update
  #   context "when is not successfully updated" do
  #     before(:each) do
  #       @user = create_and_authenticate_user(:user_admin)
  #       @item1 = FactoryGirl.create :item
  #       @item2 = FactoryGirl.create :item
  #
  #       patch :update, { id: @item2.id,
  #                         unique_name: @item1[:unique_name] }
  #     end
  #
  #     it "renders error from JSON" do
  #       item_response = json_response
  #       expect(item_response).to have_key(:errors)
  #     end
  #
  #     it { should respond_with 422 }
  #   end
  # end
  #
  # describe "DELETE #destroy" do
  #   before(:each) do
  #     @user = create_and_authenticate_user(:user_admin)
  #     @item = FactoryGirl.create :item
  #     delete :destroy, { id: @item.id }
  #   end
  #
  #   it { should respond_with 204 }
  # end
end