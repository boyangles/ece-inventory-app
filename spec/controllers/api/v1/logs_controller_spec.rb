require 'rails_helper'

describe Api::V1::LogsController do
  describe "Get #show" do
    before(:each) do
      @user = create_and_authenticate_user(:user_admin)
      @log = FactoryGirl.create :log
      get :show, id: @log.id
    end

    it "returns info on a hash" do
      log_response = json_response
      expect(log_response[:user_id]).to eql @log.user_id
    end

    it { should respond_with 200 }
  end

  describe "POST #create" do
    # Successful creation
    skip ("No longer have CREATE functionality for logs") do
      context "when successfully created" do
        before(:each) do
          @user = create_and_authenticate_user(:user_admin)
          log_attribute_creation

          @log_attributes[:user_id] = @sample_user[:id]
          @log_attributes[:item_id] = @sample_item[:id]
          post :create, @log_attributes
        end

        it "renders json representation on creation" do
          log_response = json_response
          expect(log_response[:user_id]).to eql @log_attributes[:user_id]
          expect(log_response[:item_id]).to eql @log_attributes[:item_id]
        end

        it { should respond_with 201 }
      end

      # Unsuccessful creation
      context "when not successfully created" do
        before(:each) do
          @user = create_and_authenticate_user(:user_admin)
          log_attribute_creation

          @log_attributes[:user_id] = @sample_user[:id] + 1
          @log_attributes[:item_id] = @sample_item[:id] + 1

          post :create, @log_attributes
        end

        it "renders JSON error" do
          log_response = json_response
          expect(log_response).to have_key(:errors)
        end

        it { should respond_with 422 }
      end
    end
  end

  describe "PUT/PATCH #update" do
    skip ("No longer have update functionality for logs") do
      # Successful update
      context "when is successfully updated" do
        before(:each) do
          @user = create_and_authenticate_user(:user_admin)
          @log = FactoryGirl.create :log
          patch :update, { id: @log.id,
                           quantity: 52 }
        end

        it "renders json representation on update" do
          log_response = json_response
          expect(log_response[:quantity]).to eql 52
        end

        it { should respond_with 200 }
      end

      #Unsuccessful update
      context "unsuccessful update" do
        before(:each) do
          @user = create_and_authenticate_user(:user_admin)
          @log = FactoryGirl.create :log
          patch :update, { id: @log.id,
                           item_id: -1 }
        end

        it "renders errors from JSON" do
          log_response = json_response
          expect(log_response).to have_key(:errors)
        end

        it { should respond_with 422 }
      end
    end
  end

  describe "DELETE #destroy" do
    skip ("No longer have delete functionality for logs") do
      before(:each) do
        @user = create_and_authenticate_user(:user_admin)
        @log = FactoryGirl.create :log
        delete :destroy, { id: @log.id }
      end

      it { should respond_with 204 }
    end
  end

  private
  def log_attribute_creation
    @sample_user = FactoryGirl.create :user_admin
    @sample_item = FactoryGirl.create :item

    @log_attributes = FactoryGirl.attributes_for :log
  end
end