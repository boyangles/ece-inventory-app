module SpecTestHelper
  def login_user(user)
    visit login_url
    fill_in 'Username', :with => user.username
    fill_in 'Password', :with => user.password
    click_button 'Log in'
  end
end

RSpec.configure do |config|
  config.include SpecTestHelper, :type => :feature
end