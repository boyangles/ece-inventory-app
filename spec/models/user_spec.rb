# require 'rails_helper'
# require 'capybara/rails'

# FactoryGirl.find_definitions

RSpec.describe "sign in tests", :type => :feature do
  it "displays the user's username after successful login" do
    @user = FactoryGirl.create(:approved_user)
    visit login_path
    fill_in "Username", :with => @user.username
    fill_in "Password", :with => @user.password
    click_button "Log in"
    page.all('a', :text => @user.username)
    expect(page).to have_content @user.username
    expect(page).to have_content @user.privilege
    expect(page).to have_content "Items"
    expect(page).to have_no_content "Users"
    expect(page).to have_no_content "Account Requests"
    expect(page).to have_no_content "Tags"
  end

  it "fails to login with not approved user" do
    @user = FactoryGirl.create(:email_not_confirmed_user)
    visit login_path
    fill_in "Username", with: @user.username
    fill_in "Password", with: @user.password
    click_button "Log in"
    expect(page.current_path).to eq login_path
    expect(page).to have_content "Please activate your account by following the instructions in the account confirmation email you received to proceed"
  end

  it "login with admin user" do
    @user = FactoryGirl.create(:admin)
    visit login_path
    fill_in "Username", with: @user.username
    fill_in "Password", with: @user.password
    click_button "Log in"
    expect(page).to have_content @user.username
    expect(page).to have_content @user.privilege
    expect(page).to have_content "Users"
    expect(page).to have_content "Items"
    expect(page).to have_content "Account Requests"
    expect(page).to have_content "Tags"
  end

  after :each do
    User.delete(@user)
  end

end