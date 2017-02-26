require 'support/spec_test_helper.rb'

RSpec.describe "User Controller Tests", :type => :feature do

  describe "GET index" do
    it "gets all users as admin" do
      login(:admin)
      visit users_path
      expect(page).to have_content "Users"
      expect(page).to have_selector(:link_or_button, 'Create New Account')
    end

    it "gets all users as manager" do
      login(:manager)
      visit users_path
      expect(page).to have_content "Users"
      expect(page).not_to have_selector(:link_or_button, 'Create New Account')
    end

    it "gets redirected as student" do
      login(:student)
      visit users_path
      expect(page).to have_no_content "Users"
      expect(page).to have_content "You do not have permission"
      expect(page).to have_current_path root_path
    end
  end

  describe "GET show" do
    it "gets any user as admin" do
      login(:admin)
      visit_random_user_path
    end

    it "gets any user as manager" do
      login(:manager)
      visit_random_user_path
    end

    it "does not get user as student" do
      login(:student)
      user = FactoryGirl.create(:student)
      visit user_path(user)
      expect(page).to have_current_path root_path
    end
  end

  describe "POST create" do
    it "creates a new user as an admin" do
      login(:admin)
      visit users_path
      find_link('Create New Account').click
      expect(page).to have_current_path new_user_path
      username = Faker::Name.name
      fill_in('Username', with: username)
      fill_in('Password', with: "password")
      fill_in('Confirm Password', with: "password")
      select('student', from: 'Privilege')
      find_button('Create User').click
      expect(page).to have_current_path users_path
      expect(page).to have_content(username.downcase + ' created')
    end

    describe "PATCH update" do
      it "updates an existing student priv to admin as adminUser and logs in as student user" do
        login(:admin)
        user = FactoryGirl.create(:student)
        visit user_path(user)
        expect(page).to have_current_path user_path(user)
        find_link('Edit').click
        expect(page).to have_current_path edit_user_path(user)
        select('admin', from: 'Privilege')
        find_button('Save changes').click
        expect(page).to have_current_path user_path(user)
        find('.dropdown-toggle').click
        find_link('Log out').click
        expect(page).to have_current_path root_path
        visit login_path
        fill_in('Username', with: user.username)
        fill_in('Password', with: 'password')
        find_button('Log in').click
        expect(page).to have_current_path user_path(user)
        expect(page).to have_content 'admin'
      end

      it "cannot edit as manager" do
        login(:manager)
        user = FactoryGirl.create(:student)
        visit user_path(user)
        expect(page).not_to have_selector(:link_or_button, 'Edit')
        visit edit_user_path(user)
        expect(page).to have_content 'Cannot edit account'
      end

      it "cannot edit as student" do
        login(:student)
        user = FactoryGirl.create(:student)
        visit user_path(user)
        expect(page).to have_current_path root_path
        visit edit_user_path(user)
        expect(page).to have_current_path root_path
      end
    end

    describe "DELETE destroy" do
      it "can delete users as admin" do
        login(:admin)
        user = FactoryGirl.create(:manager)
        visit users_path
        first(:link, 'delete').click
        expect(page).to have_content 'User account deleted'
      end

      it "cannot delete users as manager" do
        login(:manager)
        user = FactoryGirl.create(:manager)
        visit users_path
        expect(page).not_to have_selector(:link, 'delete')
      end
    end
  end

  private

  def visit_random_user_path
    user = FactoryGirl.create(:student)
    visit user_path(user.id)
    expect(page).to have_content user.username
    expect(page).to have_content user.privilege
    expect(page).to have_current_path user_path(user.id)
  end

end