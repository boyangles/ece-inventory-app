require 'rails_helper'

describe User do
  before { @user = FactoryGirl.build(:user_admin) }

  subject{ @user }

  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:auth_token) }

  # TODO: Change when validation of email is finalized
  xit { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_confirmation_of(:password) }
  it { should allow_value('example@duke.edu').for(:email) }
  it { should validate_uniqueness_of(:auth_token) }

  describe "#generate_authentication_token!" do
    it "generates a unique token" do
      Devise.stub(:friendly_token).and_return("auniquetoken123")
      @user.generate_authentication_token!
      expect(@user.auth_token).to eql "auniquetoken123"
    end

    it "generates another token when one has already been taken" do
      existing_user = FactoryGirl.create(:user_admin, auth_token: "auniquetoken123")
      @user.generate_authentication_token!
      expect(@user.auth_token).not_to eql existing_user.auth_token
    end
  end

  it { should be_valid }
end

RSpec.describe "sign in tests", :type => :feature do
  it "displays the students's username after successful login" do
    @user = FactoryGirl.create(:user_student)
    visit login_path
    fill_in "Username", :with => @user.username
    fill_in "Password", :with => @user.password
    click_button "Log in"
    page.all('a', :text => @user.username)
    expect(page).to have_content @user.username
    expect(page).to have_content @user.privilege
    expect(page).to have_content "Items"
    expect(page).to have_no_content "Users"
    expect(page).to have_no_content "Tags"
  end

  it "login with admin user" do
    @user = FactoryGirl.create(:user_admin)
    visit login_path
    fill_in "Username", with: @user.username
    fill_in "Password", with: @user.password
    click_button "Log in"
    expect(page).to have_content @user.username
    expect(page).to have_content @user.privilege
    expect(page).to have_content "Users"
    expect(page).to have_content "Items"
    expect(page).to have_content "Home"
    expect(page).to have_content "Account"

  end

  after :each do
    User.destroy(@user)
  end
end