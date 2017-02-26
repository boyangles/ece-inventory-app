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
      before(:each) do
        initialize_all_fields
      end

      it "no auth_token -> no access" do
        get :show, { id: @field_public_float.id }
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'Not authenticated'
      end

      it "student auth_token -> private field denial" do
        create_and_authenticate_user(:user_student)
        get :show, { id: @field_private_float.id }
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'Students may not view private fields'
      end

      it "student auth_token -> public field acceptance" do
        create_and_authenticate_user(:user_student)
        get :show, { id: @field_public_float.id }
        should respond_with 200

        expect(json_response[:private_indicator]).to be_falsey
        expect(json_response[:field_type]).to eql('float_type')
      end

      it "manager auth_token -> full access" do
        create_and_authenticate_user(:user_manager)
        get :show, { id: @field_private_float.id }
        should respond_with 200

        expect(json_response[:private_indicator]).to be_truthy
        expect(json_response[:field_type]).to eql('float_type')
      end

      it "admin auth_token -> full access" do
        create_and_authenticate_user(:user_admin)
        get :show, { id: @field_private_float.id }
        should respond_with 200

        expect(json_response[:private_indicator]).to be_truthy
        expect(json_response[:field_type]).to eql('float_type')
      end

      it "unapproved -> no access" do
        create_and_authenticate_user(:user_admin_unapproved)
        get :show, { id: @field_public_float.id }
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'Account is not approved for this action'
      end
    end

    context "not found (404)" do
      it "custom field not found" do
        create_and_authenticate_user(:user_admin)
        get :show, { id: -1 }
        response = expect_404_not_found
        expect(response[:errors]).to include 'Custom Field not found!'
      end
    end
  end

  describe "POST #create" do
    context "privilege tests (401)" do
      it "no auth_token -> no access" do
        post_public_short_text_field
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'Not authenticated'
      end

      it "student auth_token -> no access" do
        create_and_authenticate_user(:user_student)
        post_public_short_text_field
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'No sufficient privileges'
      end

      it "manager auth_token -> no access" do
        create_and_authenticate_user(:user_student)
        post_public_short_text_field
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'No sufficient privileges'
      end

      it "admin auth_token -> full access" do
        create_and_authenticate_user(:user_admin)
        post_public_short_text_field
        should respond_with 201
      end

      it "unapproved -> no access" do
        create_and_authenticate_user(:user_admin_unapproved)
        post_public_short_text_field
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'Account is not approved for this action'
      end
    end

    context "incorrect input tests (422)" do
      before(:each) do
        create_and_authenticate_user(:user_admin)
      end

      it "field type -> not enum" do
        post :create, {
            field_name: 'sample_field',
            private_indicator: false,
            field_type: 'incorrect_field_type'
        }
        response = expect_422_unprocessable_entity
        expect(response[:errors]).to include 'Inputted Field Type is not short_text_type/long_text_type/integer_type/float_type!'
      end

      it "field name -> taken" do
        custom_field = post_public_short_text_field
        post :create, {
            field_name: custom_field.field_name,
            private_indicator: false,
            field_type: 'float'
        }

        response = expect_422_unprocessable_entity
        expect(response[:errors][:field_name]).to include 'has already been taken'
      end
    end
  end

  describe "DELETE #destroy" do
    context "privilege tests (401)" do
      before(:each) do
        initialize_all_fields
      end

      it "no auth_token -> no access" do
        delete :destroy, { id: @field_public_float.id }
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'Not authenticated'
      end

      it "student auth_token -> no access" do
        create_and_authenticate_user(:user_student)
        delete :destroy, { id: @field_private_integer }
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'No sufficient privileges'
      end

      it "manager auth_token -> no access" do
        create_and_authenticate_user(:user_manager)
        delete :destroy, { id: @field_private_short_text }
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'No sufficient privileges'
      end

      it "admin auth_token -> full access" do
        create_and_authenticate_user(:user_admin)
        delete :destroy, { id: @field_public_long_text }
        should respond_with 204
      end

      it "unapproved -> no access" do
        create_and_authenticate_user(:user_admin_unapproved)
        delete :destroy, { id: @field_public_long_text }
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'Account is not approved for this action'
      end
    end

    context "not found (404)" do
      it "custom field not found" do
        create_and_authenticate_user(:user_admin)
        delete :destroy, { id: -1 }
        response = expect_404_not_found
        expect(response[:errors]).to include 'Custom Field not found!'
      end
    end
  end

  describe "PUT/PATCH #update_name" do
    context "privilege tests (401)" do
      before(:each) do
        initialize_all_fields
      end

      it "no auth_token -> no access" do
        update_public_integer_field('updated_field_name')
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'Not authenticated'
      end

      it "student auth_token -> no access" do
        create_and_authenticate_user(:user_student)
        update_public_integer_field('updated_field_name')
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'No sufficient privileges'
      end

      it "manager auth_token -> no access" do
        create_and_authenticate_user(:user_manager)
        update_public_integer_field('updated_field_name')
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'No sufficient privileges'
      end

      it "admin auth_token -> no access" do
        create_and_authenticate_user(:user_admin)
        update_public_integer_field('updated_field_name')
        should respond_with 200
      end

      it "unapproved -> no access" do
        create_and_authenticate_user(:user_admin_unapproved)
        update_public_integer_field('updated_field_name')
        response = expect_401_unauthorized
        expect(response[:errors]).to include 'Account is not approved for this action'
      end
    end

    context "incorrect inputs (422)" do
      it "field name renamed to one already taken" do
        initialize_all_fields
        create_and_authenticate_user(:user_admin)
        update_public_integer_field(@field_private_short_text.field_name)
        response = expect_422_unprocessable_entity
        expect(response[:errors][:field_name]).to include 'has already been taken'
      end
    end

    context "not found (404)" do
      it "id is not available" do
        create_and_authenticate_user(:user_admin)
        patch :update_name, {
            id: -1,
            custom_field: {
                field_name: 'sample_field_update'
            }
        }
        response = expect_404_not_found
        expect(response[:errors]).to include 'Custom Field not found!'
      end
    end
  end

  describe "PUT/PATCH #update_privacy" do
    context "privilege tests (401)" do
      it "no auth_token -> no access" do

      end

      it "student auth_token -> no access" do

      end

      it "manager auth_token -> no access" do

      end

      it "admin auth_token -> no access" do

      end

      it "unapproved -> no access" do

      end
    end
  end

  describe "PUT/PATCH #update_type" do
    context "privilege tests (401)" do
      it "no auth_token -> no access" do

      end

      it "student auth_token -> no access" do

      end

      it "manager auth_token -> no access" do

      end

      it "admin auth_token -> no access" do

      end

      it "unapproved -> no access" do

      end
    end
  end

  describe "PUT/PATCH clear_field_content" do
    context "privilege tests (401)" do
      it "no auth_token -> no access" do

      end

      it "student auth_token -> no access" do

      end

      it "manager auth_token -> no access" do

      end

      it "admin auth_token -> no access" do

      end

      it "unapproved -> no access" do

      end
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

  private
  def post_public_short_text_field
    post :create, {
        field_name: 'sample_field',
        private_indicator: false,
        field_type: 'short_text_type'
    }

    return CustomField.find_by(:field_name => 'sample_field')
  end

  def update_public_integer_field(field_name)
    patch :update_name, {
        id: @field_public_integer,
        custom_field: {
            field_name: field_name
        }
    }
  end
end