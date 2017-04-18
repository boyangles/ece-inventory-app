module SpecTestHelper
  def login(name)
    @user = FactoryGirl.create(name)
    login_as(@user)
  end

  def login_as(user)
    visit login_url
    fill_in 'Username', :with => user.username
    fill_in 'Password', :with => user.password
    click_button 'Log in'
  end


  def create_item_with_stocks(num_stocks)
    @item = create :item, has_stocks: true, quantity: num_stocks
  end

end

RSpec.configure do |config|
  config.include SpecTestHelper, :type => :feature
end