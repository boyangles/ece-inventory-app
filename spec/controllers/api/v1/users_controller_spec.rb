require 'rails_helper'
#require 'helpers/base_helper_spec'

describe Api::V1::UsersController do
  describe "GET #index" do
    context "testing privileges" do
      it "non-user cannot see anything" do
        get :index
        expect_401_unauthorized
      end

      it "students cannot see anything" do
        create_and_authenticate_user(:user_student)
        get :index

        expect_401_unauthorized
      end

      it "managers are validated" do
        create_and_authenticate_user(:user_manager)
        get :index

        should respond_with 200
      end

      it "admins are validated" do
        create_and_authenticate_user(:user_admin)
        get :index

        should respond_with 200
      end
    end

    context "testing status" do
      it "unapproved user can't do anything" do
        create_and_authenticate_user(:user_admin_unapproved)
        get :index

        expect_401_unauthorized
      end
    end

    context "when enum values (status and privilege) are incorrect" do
      before(:each) do
        @user = create_and_authenticate_user(:user_admin)
        @user_attributes = FactoryGirl.attributes_for :user_admin
      end

      it "Status is incorrect" do
        @user_attributes[:status] = 'incorrect_status'
        get :index, @user_attributes

        user_response = expect_422_unprocessable_entity
        expect(user_response[:errors]).to include "Inputted status is not approved/deactivated!"
      end

      it "Privilege is incorrect" do
        @user_attributes[:privilege] = 'incorrect_privilege'
        get :index, @user_attributes

        user_response = expect_422_unprocessable_entity
        expect(user_response[:errors]).to include "Inputted privilege is not student/manager/admin!"
      end
    end
  end

  describe "GET #show" do
    context "privilege testing" do
      it "non-user cannot see" do
        @user = FactoryGirl.create :user
        get :show, id: @user.id
        expect_401_unauthorized
      end

      it "students cannot see other people" do
        @user = create_and_authenticate_user(:user_student)
        @user_other = FactoryGirl.create :user_manager
        get :show, id: @user_other.id
        expect_401_unauthorized
      end

      it "students should be able to see themselves" do
        @user = create_and_authenticate_user(:user_student)
        get :show, id: @user.id

        should respond_with 200
      end

      it "managers are validated" do
        @user = create_and_authenticate_user(:user_manager)
        get :show, id: @user.id

        should respond_with 200
      end

      it "admins are validated" do
        @user = create_and_authenticate_user(:user_admin)
        get :show, id: @user.id

        should respond_with 200
      end
    end

    context "testing status" do
      it "unapproved user can't do anything" do
        @user = create_and_authenticate_user(:user_admin_unapproved)
        get :show, id: @user.id

        expect_401_unauthorized
      end
    end

    context "standard testing" do
      before(:each) do
        @user = create_and_authenticate_user(:user_admin)
        get :show, id: @user.id
      end

      it "returns info about a reporter on a hash" do
        user_response = json_response
        expect(user_response[:email]).to eql @user.email
      end

      it { should respond_with 200 }
    end
  end

  describe "POST #create" do
    context "when privileges are not enough" do
      before(:each) do
        @user_attributes = FactoryGirl.attributes_for :user_admin
      end

      it "non-user cannot create anything" do
        post :create, { user: @user_attributes }

        expect_401_unauthorized
      end

      it "student cannot create anything" do
        create_and_authenticate_user(:user_student)
        post :create, { user: @user_attributes }

        expect_401_unauthorized
      end

      it "manager cannot create anything" do
        create_and_authenticate_user(:user_manager)
        post :create, { user: @user_attributes }

        expect_401_unauthorized
      end
    end

    context "testing status" do
      before(:each) do
        @user_attributes = FactoryGirl.attributes_for :user_admin
      end

      it "unapproved user can't do anything" do
        create_and_authenticate_user(:user_admin_unapproved)
        post :create, { user: @user_attributes }

        expect_401_unauthorized
      end
    end

    context "when enum values (status and privilege) are incorrect" do
      before(:each) do
        @user = create_and_authenticate_user(:user_admin)
        @user_attributes = FactoryGirl.attributes_for :user_admin
      end

      it "Status is incorrect" do
        @user_attributes[:status] = 'incorrect_status'
        post :create, { user: @user_attributes }

        user_response = expect_422_unprocessable_entity
        expect(user_response[:errors]).to include "Inputted status is not approved/deactivated!"
      end

      it "Privilege is incorrect" do
        @user_attributes[:privilege] = 'incorrect_privilege'
        post :create, { user: @user_attributes }

        user_response = expect_422_unprocessable_entity
        expect(user_response[:errors]).to include "Inputted privilege is not student/manager/admin!"
      end
    end

    # Successful user creation
    context "when is successfully created" do
      before(:each) do
        @user = create_and_authenticate_user(:user_admin)
        @user_attributes = FactoryGirl.attributes_for :user_admin

        post :create, { user: @user_attributes }
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
        @user = create_and_authenticate_user(:user_admin)
        @invalid_user_attributes = { password: "password",
                                     password_confirmation: "invalid_password" }
        post :create, { user: @invalid_user_attributes }
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

  describe "PUT/PATCH #update_password" do
    context "testing privileges" do
      it "non-users cannot update" do
        user = FactoryGirl.create :user_student
        update_action_and_expect_unauthorized(:update_password, :user, user, {
            password: 'password',
            password_confirmation: 'password'
        })
      end

      it "students cannot update password of others" do
        create_and_authenticate_user(:user_student)
        user_other = FactoryGirl.create :user_manager

        update_action_and_expect_unauthorized(:update_password, :user, user_other, {
            password: 'password',
            password_confirmation: 'password'
        })
      end

      it "managers cannot update password of others" do
        create_and_authenticate_user(:user_manager)
        user_other = FactoryGirl.create :user_student

        update_action_and_expect_unauthorized(:update_password, :user, user_other, {
            password: 'password',
            password_confirmation: 'password'
        })
      end

      it "admins cannot update password of others" do
        create_and_authenticate_user(:user_admin)
        user_other = FactoryGirl.create :user_student

        update_action_and_expect_unauthorized(:update_password, :user, user_other, {
            password: 'password',
            password_confirmation: 'password'
        })
      end

      it "students can update password of self" do
        user = create_and_authenticate_user(:user_student)
        update_action_and_expect_ok(:update_password, :user, user, {
            password: 'password',
            password_confirmation: 'password'
        })
      end

      it "managers can update password of self" do
        user = create_and_authenticate_user(:user_manager)
        update_action_and_expect_ok(:update_password, :user, user, {
            password: 'password',
            password_confirmation: 'password'
        })
      end

      it "admins can update password of self" do
        user = create_and_authenticate_user(:user_admin)
        update_action_and_expect_ok(:update_password, :user, user, {
            password: 'password',
            password_confirmation: 'password'
        })
      end
    end

    context "testing status" do
      it "unapproved user can't do anything" do
        user = create_and_authenticate_user(:user_admin_unapproved)

        update_action_and_expect_unauthorized(:update_password, :user, user, {
            password: 'password',
            password_confirmation: 'password'
        })
      end
    end

    context "testing password mismatch" do
      before(:each) do
        @user = create_and_authenticate_user(:user_admin)

        patch :update_password, {
            id: @user.id,
            user: {
                password: 'new_password',
                password_confirmation: 'incorrect_new_password'
            }
        }
      end

      it "mismatched passwords" do
        user_response = expect_422_unprocessable_entity
        expect(user_response[:errors][:password_confirmation]).to include "doesn't match Password"
      end
    end
  end

  describe "PUT/PATCH #update_status and #update_privilege" do
    context "testing privileges" do
      it "non-users cannot update anybody's status or privilege" do
        user = FactoryGirl.create :user_student

        update_action_and_expect_unauthorized(:update_status, :user, user, { status: 'approved' })
        update_action_and_expect_unauthorized(:update_privilege, :user, user, { privilege: 'admin' })
      end

      it "students cannot update anybody's status or privilege" do
        user = create_and_authenticate_user(:user_student)
        user_other = FactoryGirl.create :user_manager

        update_action_and_expect_unauthorized(:update_status, :user, user, { status: 'approved' })
        update_action_and_expect_unauthorized(:update_status, :user, user_other, { status: 'approved' })

        update_action_and_expect_unauthorized(:update_privilege, :user, user, { privilege: 'admin' })
        update_action_and_expect_unauthorized(:update_privilege, :user, user_other, { privilege: 'admin' })
      end

      it "managers cannot update anybody's status or privilege" do
        user = create_and_authenticate_user(:user_manager)
        user_other = FactoryGirl.create :user_student

        update_action_and_expect_unauthorized(:update_status, :user, user, { status: 'approved' })
        update_action_and_expect_unauthorized(:update_status, :user, user_other, { status: 'approved' })

        update_action_and_expect_unauthorized(:update_privilege, :user, user, { privilege: 'admin' })
        update_action_and_expect_unauthorized(:update_privilege, :user, user_other, { privilege: 'admin' })
      end

      it  "admins cannot update status or privilege of self" do
        user = create_and_authenticate_user(:user_admin)
        update_action_and_expect_unauthorized(:update_status, :user, user, { status: 'approved' })
        update_action_and_expect_unauthorized(:update_privilege, :user, user, { privilege: 'admin' })
      end

      it "admins can update status or privilege of others" do
        create_and_authenticate_user(:user_admin)
        user_other = FactoryGirl.create :user_student

        update_action_and_expect_ok(:update_status, :user, user_other, { status: 'approved' })
        update_action_and_expect_ok(:update_privilege, :user, user_other, { privilege: 'admin' })
      end
    end

    context "testing status" do
      it "unapproved user cannot update anybody's status or privilege" do
        user = create_and_authenticate_user(:user_admin_unapproved)
        user_other = FactoryGirl.create :user_student

        update_action_and_expect_unauthorized(:update_status, :user, user, { status: 'approved' })
        update_action_and_expect_unauthorized(:update_status, :user, user_other, { status: 'approved' })

        update_action_and_expect_unauthorized(:update_privilege, :user, user, { privilege: 'admin' })
        update_action_and_expect_unauthorized(:update_privilege, :user, user_other, { privilege: 'admin' })
      end
    end

    context "enum for status and privilges" do
      before(:each) do
        create_and_authenticate_user(:user_admin)
        @user_other = FactoryGirl.create :user_student
      end

      it "incorrect status" do
        update_action(:update_status, :user, @user_other, { status: 'incorrect_status' })
        user_response_status = expect_422_unprocessable_entity
        expect(user_response_status[:errors]).to include "Inputted status is not approved/deactivated!"
      end

      it "incorrect privilege" do
        update_action(:update_privilege, :user, @user_other, { privilege: 'incorrect_privilege' })
        user_response_privilege = expect_422_unprocessable_entity
        expect(user_response_privilege[:errors]).to include "Inputted privilege is not student/manager/admin!"
      end
    end
  end

  describe "DELETE #destroy" do
    it "non-users cannot delete anybody" do
      user = FactoryGirl.create :user_student
      delete_action_and_expect_unauthorized(:destroy, user, "Not authenticated")
    end

    it "students cannot delete anybody (themselves or others)" do
      user = create_and_authenticate_user(:user_student)
      user_other = FactoryGirl.create :user_manager

      delete_action_and_expect_unauthorized(:destroy, user, "No sufficient privileges")
      delete_action_and_expect_unauthorized(:destroy, user_other, "No sufficient privileges")
    end

    it "managers cannot delete anybody (themselves or others)" do
      user = create_and_authenticate_user(:user_manager)
      user_other = FactoryGirl.create :user_student

      delete_action_and_expect_unauthorized(:destroy, user, "No sufficient privileges")
      delete_action_and_expect_unauthorized(:destroy, user_other, "No sufficient privileges")
    end

    it "admins cannot delete themselves" do
      user = create_and_authenticate_user(:user_admin)
      delete_action_and_expect_unauthorized(:destroy, user, "Action cannot be done on yourself")
    end

    it "admins can delete others" do
      create_and_authenticate_user(:user_admin)
      user_other = FactoryGirl.create :user_manager

      delete :destroy, { id: user_other.id }
      should respond_with 204
    end
  end

  ## Private methods

  private
  def delete_action_and_expect_unauthorized(action, input_obj, expected_error_msg)
    delete action, { id: input_obj.id }
    response = expect_401_unauthorized
    expect(response[:errors]).to include expected_error_msg
  end

  private
  def update_action(action, obj_type, input_obj, param_hash)
    patch action, {
        id: input_obj.id,
        obj_type => param_hash
    }
  end

  private
  def update_action_and_expect_unauthorized(action, obj_type, input_obj, param_hash)
    update_action(action, obj_type, input_obj, param_hash)
    expect_401_unauthorized
  end

  private
  def update_action_and_expect_ok(action, obj_type, input_obj, param_hash)
    update_action(action, obj_type, input_obj, param_hash)
    should respond_with 200
  end
end
