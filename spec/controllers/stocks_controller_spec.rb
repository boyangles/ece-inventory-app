require 'rails_helper'
require 'pry'


feature "Stocks Controller Spec Test" do


  feature 'GET' do

  end

  feature 'DESTROY' do

    before :each do
      create_item_with_stocks(1)
    end

    scenario 'Admin can delete stocks' do
      login(:user_admin)
      visit item_stocks_path @item
      initial_quantity = @item.quantity
      expect(page).to have_selector(:link_or_button, 'Delete')
      click_on('Delete')
      expect(page).to have_content('Asset Deleted')
      @item.reload
      expect(@item.quantity).to eq(Stock.where(item_id: @item.id).count)
      expect(@item.quantity).to eq(initial_quantity-1)
    end

    scenario 'Manager cannot see delete or edit stocks button' do
      login(:user_manager)
      visit item_stocks_path @item
      expect(page).to have_no_selector(:link_or_button, 'Delete')
      expect(page).to have_no_selector(:link_or_button, 'Edit')
    end

  end

  feature 'INDEX' do

    before :all do
      create_item_with_stocks(21)
    end

    scenario 'verify UI for stocks index' do
      login(:user_admin)
      visit item_path(@item)
      expect(page).to have_selector(:link_or_button, 'Show Assets')
      click_on('Show Assets')
      expect(page).to have_current_path item_stocks_path(@item)
      verify_index_UI(@item)
      expect(page).to have_selector(:link_or_button, '2')
      click_on('2')
      expect(page).to have_current_path item_stocks_path(@item, page: 2)
      verify_index_UI(@item)
    end

    scenario 'student cannot visit index page' do
      login(:user_student)
      visit item_path @item
      expect(page).to have_no_selector(:link_or_button, 'Show Assets')
      visit item_stocks_path @item
      expect(page).to have_current_path root_path
      expect(page).to have_content 'You do not have permission to perform this operation'
    end
  end

  feature "Convert item to stocks" do

    before :each do
      @item = create :item
    end

    scenario 'admin converts item to stocks' do
      login(:user_admin)
      visit item_path(@item)
      expect(page).to have_selector(:link_or_button, 'Convert to Assets')
      click_on('Convert to Assets')
      expect(page).to have_current_path item_stocks_path @item
      expect(page).to have_content('Item successfully converted')
      @item.reload
      expect(@item.quantity).to eq (Stock.where(item_id: @item.id).count)
    end

    scenario 'manager converts item to stocks' do
      login(:user_manager)
      visit item_path(@item)
      expect(page).to have_selector(:link_or_button, 'Convert to Assets')
      click_on('Convert to Assets')
      expect(page).to have_current_path item_stocks_path @item
      expect(page).to have_content('Item successfully converted')
      @item.reload
      expect(@item.quantity).to eq (Stock.where(item_id: @item.id).count)
    end

    scenario 'student cannot convert item to stocks' do
      login(:user_student)
      visit item_path(@item)
      expect(page).to have_no_selector(:link_or_button, 'Convert to Assets')
    end

  end

end

private

def verify_index_UI(item)
  expect(page).to have_content item.unique_name
  expect(page).to have_selector(:link_or_button, 'Create Asset')
end