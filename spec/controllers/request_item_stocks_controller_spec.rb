require 'rails_helper'
require 'helpers/base_helper_spec'
require 'pry'


feature 'Requests Integration with Stocks Tests' do



  feature 'Student placing request' do

    before :each do
      login(:user_student)
      @item = create :item, quantity: 5
      @item2 = create :item, quantity: 6
    end

    scenario 'student places request with stock item' do
      visit item_path @item
      expect(@item.convert_to_stocks).to eq true
      fill_in('loan_id', with: 2)
      fill_in('disburse_id', with: 0)
      click_on 'Add to Cart'
      verify_cart_fields_UI(@item, @user)
      fill_in('request_response', with: 'a reason')
      find_button("Place Order", match: :first).click
      expect(page).to have_content 'Operation successful!'
      expect(page).to have_content 'Outstanding'

      verify_outstanding_request_fields_UI(@item, @user)

      # Need to add serial tags in here




    end

    scenario 'student places request with multiple items, mixed bag' do

    end

    scenario 'student can place request with regular item' do

    end

    scenario 'student places request with loans and disbursements' do

    end

  end


  feature 'privilege checks on requests' do

  end

  feature 'specifying serial tags' do

    scenario 'student cannot specify serial tags 'do

    end

    scenario 'manager can specify serial tags' do

    end

    scenario 'admin can specify serial tags' do

    end

  end

  feature 'returning items' do

    scenario 'student cannot return items' do


    end

    scenario 'manager can return regular item' do

    end

    scenario 'admin can return regular item' do

    end

    scenario 'manager can return stocked item' do

    end

    scenario 'admin can return stocked item' do

    end

    scenario 'can return items in mixed bag' do

    end

    scenario 'can return loan in increments' do

    end

    scenario 'cannot return a disbursed item' do

    end

  end

  private

  def verify_cart_fields_UI(item, user)
    request_item = RequestItem.where(item_id: item.id)
    expect(page).to have_content 'Item Name'
    expect(page).to have_content 'Requested for Loan'
    expect(page).to have_content 'Requested for Disbursement'
    expect(page).to have_selector(:link_or_button, 'Specify Serial Tags') if check_user_is_manager_or_admin(user) && item.has_stocks
    expect(page).to have_selector(:link_or_button, 'Remove Item')
    expect(page).to have_content 'User to Make Request For' if check_user_is_manager_or_admin(user)
    expect(page).to have_selector(:link_or_button, 'Place Order')
    expect(page).to have_selector(:link_or_button, 'Clear Cart')

    expect(page).to have_content item.unique_name
    binding.pry
    expect(page).to have_content request_item.quantity_loan
    expect(page).to have_content request_item.quantity_disburse

  end

  def verify_outstanding_request_fields_UI(item, user)
    request_item = RequestItem.find(item_id: item.id)
    expect(page).to have_content 'Requested by ' + user.username
    expect(page).to have_content item.unique_name
    expect(page).to have_content request_item.quantity_loan
    expect(page).to have_content request_item.quantity_disburse
    expect(page).to have_selector(:link_or_button, 'Approve')
    expect(page).to have_selector(:link_or_button, 'Deny')
    expect(page).to have_selector(:link_or_button, 'Specify Serial Tags') if check_user_is_manager_or_admin(user) && item.has_stocks


    if item.has_stocks
      # TODO place serial tags on shit
    end



  end




end
