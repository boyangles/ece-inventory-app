require 'support/spec_test_helper.rb'

RSpec.describe "Create Item Tests", :type => :feature do


  it "Navigate to new item as admin" do
    @admin = FactoryGirl.create(:admin)
    login_user(@admin)
    visit items_path
    expect(page).to have_content 'New Item'
    click_link 'New Item'
    expect(page).to have_content 'New Item'
    expect(page.current_path).to eq new_item_path
  end

  after :each do
    User.destroy(@admin)
  end

end