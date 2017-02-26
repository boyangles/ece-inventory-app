require 'rails_helper'

describe Api::V1::CustomFieldsController do
  describe "GET #index" do
    context "privilege tests (401)" do
      before(:each) do
        initialize_private_fields
        initialize_public_fields

        @total_public_field_count = CustomField.where(:private_indicator => false).count
        @total_private_field_count = CustomField.where(:private_indicator => true).count
        @total_field_count = CustomField.count
      end

      it "no auth_token -> no access" do
        get :index
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'Not authenticated'
      end
      
      it "student auth_token -> only public fields" do
        create_and_authenticate_user(:user_student)
        get :index
        should respond_with 200

        json_response.each do |cf|
          expect(cf[:private_indicator]).to be_falsey
        end

        expect(json_response.count).to eql(@total_private_field_count)
      end
      
      it "manager auth_token -> all fields" do
        create_and_authenticate_user(:user_manager)
        get :index
        should respond_with 200

        expect(json_response.count).to eql(@total_field_count)
      end
      
      it "admin auth_token -> all fields" do
        create_and_authenticate_user(:user_admin)
        get :index
        should respond_with 200

        expect(json_response.count).to eql(@total_field_count)
      end

      it "unapproved -> no access" do
        create_and_authenticate_user(:user_admin_unapproved)
        get :index
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'Account is not approved for this action'
      end
    end
    
    context "incorrect input tests (422)" do
      it "field type -> not enum" do
        create_and_authenticate_user(:user_admin)
        get :index, {
            field_type: 'incorrect_field_type'
        }
        response = expect_422_unprocessable_entity
        expect(response[:errors]).to include 'Inputted Field Type is not short_text_type/long_text_type/integer_type/float_type!'
      end
    end

    context "standard operation (200)" do
      before(:each) do
        create_and_authenticate_user(:user_admin)
        initialize_all_fields

        @total_public_field_count = CustomField.where(:private_indicator => false).count
        @total_private_field_count = CustomField.where(:private_indicator => true).count
        @total_field_count = CustomField.count

        @sample_field_name_private_integer = CustomField.
            find_by(:private_indicator => true, :field_type => 'integer_type').field_name
      end

      it "query -> no query" do
        get :index
        should respond_with 200
        expect(json_response.count).to eql(@total_field_count)
      end

      it "query -> field_name only" do
        get :index, { field_name: @sample_field_name_private_integer }
        should respond_with 200
        json_response.each do |cf|
          expect(cf[:field_name]).to eql(@sample_field_name_private_integer)
        end
        expect(json_response.count).to eql 1
      end

      it "query -> private_indicator only" do
        get :index, { private_indicator: true }
        should respond_with 200
        json_response.each do |cf|
          expect(cf[:private_indicator]).to be_truthy
        end
        expect(json_response.count).to eql @total_public_field_count
      end

      it "query -> field_type only" do
        get :index, { field_type: 'float_type' }
        should respond_with 200
        json_response.each do |cf|
          expect(cf[:field_type]).to eql('float_type')
        end
        expect(json_response.count).to eql 2
      end
    end
  end

  describe "GET #show" do
    context "privilege tests (401)" do

    end
  end

  describe "POST #create" do
    context "privilege tests (401)" do

    end
  end

  describe "DELETE #destroy" do
    context "privilege tests (401)" do

    end
  end

  describe "PUT/PATCH #update_name" do
    context "privilege tests (401)" do

    end
  end

  describe "PUT/PATCH #update_privacy" do
    context "privilege tests (401)" do

    end
  end

  describe "PUT/PATCH #update_type" do
    context "privilege tests (401)" do

    end
  end

  describe "PUT/PATCH clear_field_content" do
    context "privilege tests (401)" do

    end
  end

  ## Private methods
  private
  def initialize_all_fields
    initialize_private_fields
    initialize_public_fields
  end

  private
  def initialize_public_fields
    @field_public_short_text = FactoryGirl.create :field_public_short_text
    @field_public_long_text = FactoryGirl.create :field_public_long_text
    @field_public_integer = FactoryGirl.create :field_public_integer
    @field_public_float = FactoryGirl.create :field_public_float
  end

  private
  def initialize_private_fields
    @field_private_short_text = FactoryGirl.create :field_private_short_text
    @field_private_long_text = FactoryGirl.create :field_private_long_text
    @field_private_integer = FactoryGirl.create :field_private_integer
    @field_private_float = FactoryGirl.create :field_private_float
  end
end