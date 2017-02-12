RSpec.describe "home page", :type => :feature do
  it "displays the user's username after successful login" do
    #user = FactoryGirl.create(:user, :username => "jdoe", :password => "secret")
    user = User.create!(username: "jdoe", email: "jaiefn@duke.edu", password: "password", privilege: "admin",
                        status: "approved")
    visit "/login"
    fill_in "Username", :with => "jdoe"
    fill_in "Password", :with => "password"
    click_button "Log in"

    page.all('a', :text => 'jdoe')
  end

  it "logs in as admin from seeds.rb" do
    user = User.find_by(username: "admin")
    assert user
    visit "/login"
    fill_in "Username", :with => "admin"
    fill_in "Password", :with => "password"
    click_button "Log in"

    page.all('a', :text => 'admin')
  end
end