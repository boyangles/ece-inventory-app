require 'rails_helper'
require 'capybara/rails'

RSpec.describe "home page", :type => :feature do
  it "displays the user's username after successful login" do
    #user = FactoryGirl.create(:user, :username => "jdoe", :password => "secret")
    user = User.create!(username: "jdoe", email: "jaiefn@duke.edu", password: "password", privilege: "admin",
                        status: "approved", email_confirmed: "true")
    visit "/login"
    fill_in "Username", :with => "jdoe"
    fill_in "Password", :with => "password"
    click_button "Log in"

    page.all('a', :text => 'jdoe')
  end
end