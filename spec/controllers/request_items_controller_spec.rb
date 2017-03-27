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
      login(:user_student)
      add_item_to_cart(@item, -1, 2)
      expect(page).to have_content "You may not add this to the cart! Error: Validation failed: Quantity loan must be greater than or equal to 0"
      expect(page).to have_current_path item_path(@item.id)

      add_item_to_cart(@item, 2, -1)
      expect(page).to have_content "You may not add this to the cart! Error: Validation failed: Quantity disburse must be greater than or equal to 0"
      expect(page).to have_current_path item_path(@item.id)

      add_item_to_cart(@item, -1, -1)
      expect(page).to have_content "Error: Validation failed: Quantity loan must be greater than or equal to 0, Quantity disburse must be greater than or equal to 0"
      expect(page).to have_current_path item_path(@item.id)
    end

    scenario "cannot add duplicate items to cart" do

    end

  end

  feature "Remove Items from cart" do

    before :each do
      @item = create :item
      @item2 = create :item
      @item3 = create :item
    end

    # It would be better to do exact matches, aka Remove Item has the id: remove_Item_ID on it or something
    scenario "student deletes item from own cart" do
      login(:user_student)
      add_item_to_cart(@item, 10, 10)
      add_item_to_cart(@item2, 20, 20)
      add_item_to_cart(@item3, 30, 30)
      expect(page).to have_content @item.unique_name
      expect(page).to have_content @item2.unique_name
      expect(page).to have_content @item3.unique_name
      click_link('Remove Item', match: :first)
      expect(page).to have_no_content @item.unique_name
      expect(page).to have_content @item2.unique_name
      expect(page).to have_content @item3.unique_name
      click_link('Remove Item', match: :first)
      expect(page).to have_no_content @item.unique_name
      expect(page).to have_no_content @item2.unique_name
      expect(page).to have_content @item3.unique_name
      click_link('Remove Item', match: :first)
      expect(page).to have_no_content @item.unique_name
      expect(page).to have_no_content @item2.unique_name
      expect(page).to have_no_content @item3.unique_name
    end
  end

  feature "Placing order" do
    before :each do
      @item = create :item
      @item2 = create :item
      @item3 = create :item
    end

    scenario "student places order" do
      login(:user_student)
      add_item_to_cart(@item, 10, 10)
      add_item_to_cart(@item2, 20, 20)
      add_item_to_cart(@item3, 30, 30)
      reason = "sick order! very nice!"
      find_button("Place Order", match: :first).click
      fill_in('Reason for request?', with: reason)
      within(".modal-dialog") do
        click_on('Place Order')
      end
      expect(page).to have_content(reason)
      verify_submitted_order_default_text_fields(@user)
      item_params = RequestItem.where(request_id: Request.select(:id).where(user_id: @user.id))
      item_params.each do |f|
        expect(page).to have_content(f.quantity_loan)
        expect(page).to have_content(f.quantity_disburse)
      end
    end


    scenario "admin places order" do
      login(:user_admin)
      add_item_to_cart(@item, 10, 10)
      add_item_to_cart(@item2, 20, 20)
      add_item_to_cart(@item3, 30, 30)
      reason = "sick order my dude! very nice!"
      find_button("Place Order", match: :first).click
      fill_in('Reason for request?', with: reason)
      within(".modal-dialog") do
        click_on('Place Order')
      end
      expect(page).to have_content(reason)
      verify_submitted_order_default_text_fields(@user)

      item_params = RequestItem.where(request_id: Request.select(:id).where(user_id: @user.id))
      item_params.each do |f|
        expect(page).to have_content(f.quantity_loan)
        expect(page).to have_content(f.quantity_disburse)
        expect(page).to have_content(f.quantity_return)
        if f.quantity_return > 0
          expect(page).to have_selector(:link_or_button, "Return")
          expect(page).to have_selector(:link_or_button, "Convert to Disbursement")
        end
      end
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
    expect(page).to have_selector :link_or_button, 'Remove Item'

    visit item_path(@item2)
    loan2 = 1
    dis2 = 0
    add_item_to_cart(@item2, loan2, dis2)
    verify_cart_default_text_fields(@user)

    expect(page).to have_content @item.unique_name
    expect(page).to have_content loan1
    expect(page).to have_content dis1
    expect(page).to have_content @item2.unique_name
    expect(page).to have_content loan2
    expect(page).to have_content dis2
    expect(page).to have_selector :link_or_button, 'Remove Item'
  end

  def add_item_to_cart(item, loan_quantity, disburse_quantity)
    visit item_path(item)
    fill_in("loan_id", with: loan_quantity)
    fill_in("disburse_id", with: disburse_quantity)
    click_button("Add to Cart")
  end

  def verify_submitted_order_default_text_fields(user)
    expect(page).to have_content("Operation successful!")
    expect(page).to have_content( (user.privilege_student? ? "Outstanding" : "Approved") )
    expect(page).to have_content("Requested by #{user.username}")
    expect(page).to have_content("Item Name")
    expect(page).to have_content( (user.privilege_student? ? "Requested for Loan" : "Quantity Loaned") )
    expect(page).to have_content( (user.privilege_student? ? "Requested for Disbursement" : "Quantity Disbursed") )
    expect(page).to have_content("Quantity Returned") if !user.privilege_student?
    expect(page).to have_content("Reason")
    expect(page).to have_content("Admin Response") if !user.privilege_student?
  end


  def verify_cart_default_text_fields(user)
    expect(page).to have_current_path request_path(Request.find_by(user_id: user.id).id)
    expect(page).to have_content 'Your Cart'
    expect(page).to have_content 'Item Name'
    expect(page).to have_content 'Requested for Loan'
    expect(page).to have_content 'Requested for Disbursement'
    expect(page).to have_content 'User to Make Request For' if user.privilege_admin? || user.privilege_manager?
    expect(page).to have_selector :link_or_button, 'Clear Cart'
    expect(page).to have_selector :link_or_button, 'Place Order'
  end

end
