require 'rails_helper'
require 'pry'


RSpec.describe "Item Controller Tests", :type => :feature do

  feature "Add items to cart" do

    before :each do
      @item = create :item
      @item2 = create :item
    end

    scenario "it adds multiple items to cart as student" do
      login(:user_student)
      adding_multiple_items
    end

    scenario "it adds multiple items to cart as manager" do
      login(:user_manager)
      adding_multiple_items
    end

    scenario "it adds multiple items to cart as admin" do
      login(:user_admin)
      adding_multiple_items
    end

    scenario "cannot add item to cart with 0 requested" do
      # Needs to be implemented
    end

    scenario "cannot add item to cart with negative requested" do
      # needs to be implemented
    end



  end


  def adding_multiple_items
    loan1 = 5
    dis1 = 10
    add_item_to_cart(@item, loan1, dis1)
    verify_cart_default_text_fields(@user)

    expect(page).to have_content @item.unique_name
    expect(page).to have_content loan1
    expect(page).to have_content dis1
    expect(page).to have_selector :button, 'Remove Item'

    visit item_path(@item2)
    loan2 = 1
    dis2 = 0
    add_item_to_cart(@item2, loan2, dis2)
    verify_cart_default_text_fields(@user)

    expect(page).to have_content @item.unique_name
    expect(page).to have_content loan
    expect(page).to have_content dis
    expect(page).to have_content @item2.unique_name
    expect(page).to have_content loan2
    expect(page).to have_content dis2
    expect(page).to have_selector :button, 'Remove Item'
  end

  def add_item_to_cart(item, loan_quantity, disburse_quantity)
    visit item_path(@item)
    fill_in("loan_id", with: loan_quantity)
    fill_in("disburse_id", with: disburse_quantity)
    click_button("Add to Cart")
  end


  def verify_cart_default_text_fields(user)
    expect(page).to have_current_path request_path(Request.find_by(user_id: user.id).id)
    expect(page).to have_content 'Your Cart' # For some reason, can't find this now, but it's on UI
    expect(page).to have_content 'Item Name'
    expect(page).to have_content 'Requested for Loan'
    expect(page).to have_content 'Requested for Disbursement'
    expect(page).to have_content 'User to Make Request For' if user.privilege_admin? || user.privilege_manager?
    expect(page).to have_selector :link_or_button, 'Clear Cart'
    expect(page).to have_selector :link_or_button, 'Place Order'
  end

end
