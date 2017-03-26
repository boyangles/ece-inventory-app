require 'support/spec_test_helper.rb'
require 'pry'

RSpec.describe "Item Controller Tests", :type => :feature do

  describe "GET index" do
    it "gets all items as admin and checks New Item option is listed" do
      login(:user_admin)
      check_items_index(@user)
    end

    it "gets all items as manager" do
      login(:user_manager)
      check_items_index(@user)
    end

    it "gets all items as student" do
      login(:user_student)
      check_items_index(@user)
    end
  end

  describe "GET show" do
    it "gets a specific item and displays info as admin" do
      login(:user_admin)
      navigate_to_new_item
      verify_show_item_details_page(@user)
    end

    it "gets a specific item and displays info as manager" do
      login(:user_manager)
      navigate_to_new_item
      verify_show_item_details_page(@user)
    end

    it "gets a specific item and displays info as student" do
      login(:user_student)
      navigate_to_new_item
      verify_show_item_details_page(@user)
    end
  end

  describe "POST create" do
    it "can create an item as an admin" do
      login(:user_admin)
      create_new_item
    end

    it "can create an item as manager" do
      login(:user_manager)
      create_new_item
    end

    it "cannot create an item as student" do
      login(:user_student)
      visit items_path
      expect(page).not_to have_selector(:link_or_button, 'New Item')
      visit new_item_path
      expect(page).to have_content 'You do not have permission to perform this operation'
      expect(page).to have_current_path root_path
    end

  end

  describe "PATCH update" do
    it "can update an item as admin" do
      login(:user_admin)
      navigate_to_new_item
      find_link('Edit Item').click
      verify_item_parameters
      updated_name = Faker::Name.name
      fill_in('Name', with: updated_name)
      fill_in('Description', with: 'updated description')
      fill_in('Model Number', with: '12n20')
      find_button('Submit').click
      updated_item = Item.find_by(unique_name: updated_name)
      expect(page).to have_current_path item_path(updated_item.id)
      verify_item_fields(updated_item)
    end

    it "can update item as manager" do
      login(:user_manager)
      navigate_to_new_item
      find_link('Edit Item').click
      updated_name = Faker::Name.name
      fill_in('Name', with: updated_name)
      find_button('Submit').click
      updated_item = Item.find_by(unique_name: updated_name)
      expect(page).to have_current_path item_path(updated_item.id)
      verify_item_fields(updated_item)
    end

    it "can update item as admin" do
      login(:user_admin)
      navigate_to_new_item
      loans=2
      disbursement=3
      fill_in('loan_id', with: loans)
      fill_in('disburse_id', with: disbursement)
      find_button('Add to Cart').click
      expect(page).to have_content(@item.unique_name)
      expect(page).to have_content(loans)
      expect(page).to have_content(disbursement)
      expect(page).to have_selector(:link_or_button, 'Remove Item')
      verify_cart_fields(@user)
    end

    it "cannot update item as student" do
      login(:user_student)
      navigate_to_new_item
      expect(page).not_to have_selector(:link_or_button, 'Edit Item Details')
      visit edit_item_path(@item.id)
      expect(page).to have_content 'You do not have permission to perform this operation'
    end

    it "can update quantity as manager" do
      login(:user_manager)
      navigate_to_new_item
      old_quantity = @item.quantity
      click_link('Edit Item')
      verify_item_parameters
      fill_in('Description', with: 'new description')
      fill_in('quantity_change', with: 10)
      expect(page).to have_content('Reason for Change')
      click_button('Submit')
      expect(@item.reload.quantity).to eq(old_quantity+10)
    end

    it "can update quantity as admin" do
      login(:user_admin)
      navigate_to_new_item
      old_quantity = @item.quantity
      click_link('Edit Item')
      verify_item_parameters
      fill_in('Description', with: 'new description')
      fill_in('quantity_change', with: 10)
      expect(page).to have_content('Reason for Change')
      click_button('Submit')
      expect(@item.reload.quantity).to eq(old_quantity+10)
    end

  end

  describe "DELETE destroy" do
    it "can delete an item as admin" do
      login(:user_admin)
      navigate_to_new_item
      # TODO: Figure out driver to accept confirmation dialog
      expect(page).to have_selector(:link_or_button, 'Delete Item')
    end

    it "cannot delete item as manager" do
      login(:user_manager)
      navigate_to_new_item
      expect(page).not_to have_selector(:link_or_button, 'Delete Item')
    end

    it "cannot delete item as student" do
      login(:user_student)
      navigate_to_new_item
      expect(page).not_to have_selector(:link_or_button, 'Delete Item')
    end
  end

  after :each do |example|
    unless example.metadata[:skip_after]
      if(@user != nil)
        User.destroy(@user)
      end
      if(@item != nil)
        @item.deactivate
      end
    end
  end

  private

  def create_new_item
    visit items_path
    find_link('New Item').click
    verify_new_item_form_fields
    item_name = Faker::Name.name
    fill_in_new_item_fields(item_name)
    find_button('Submit').click
    item = Item.find_by(unique_name: item_name)
  end

  def verify_item_fields(item)
    #expect(page).to have_current_path item_path(item.id)
    expect(page).to have_content item.unique_name
    expect(page).to have_content item.quantity
    expect(page).to have_content item.model_number
    expect(page).to have_content item.description
  end

  def verify_item_parameters
    expect(page).to have_content 'Unique Name'
    expect(page).to have_content 'Quantity Change'
    expect(page).to have_content 'Description'
    expect(page).to have_content 'Model Number'
    expect(page).to have_content 'Tags'
  end

  def fill_in_new_item_fields(name)
    fill_in('Name', with: name)
    fill_in('Quantity', with: 3)
    fill_in('Description', with: 'A nice description')
    fill_in('Model Number', with: 'Ab123')
  end

  def verify_cart_fields(user)
    expect(page).to have_content 'Item Name'
    expect(page).to have_content 'Requested for Loan'
    expect(page).to have_content 'Requested for Disbursement'
    if user.privilege_admin? || user.privilege_manager?
      expect(page).to have_content 'User to Make Request For'
    end
    expect(page).to have_selector(:button, 'Place Order')
    expect(page).to have_content 'Clear Cart'
  end

  def verify_new_item_form_fields
    expect(page).to have_current_path new_item_path
    expect(page).to have_content 'Name'
    expect(page).to have_content 'Quantity'
    expect(page).to have_content 'Description'
    expect(page).to have_content 'Model Number'
    expect(page).to have_content 'Tags'
    expect(page).to have_selector(:link_or_button, 'Submit')
  end

  def verify_show_item_details_page(user)
    expect(page).to have_content 'Main Details'
    expect(page).to have_content 'In Stock'
    expect(page).to have_content 'Model Number'
    expect(page).to have_content 'Description'
    expect(page).to have_content 'Tags'
    expect(page).to have_content 'Additional Information'
    expect(page).to have_content (!user.privilege_student? ? 'All Outstanding Requests' : 'My Outstanding Requests')
    expect(page).to have_content 'Loans'
    expect(page).to have_content 'Loan'
    expect(page).to have_content 'Disbursement'
    expect(page).to have_selector(:link_or_button, 'Add to Cart')
    if user.privilege_admin? || user.privilege_manager?
      expect(page).to have_content 'Logs'
      expect(page).to have_selector(:link_or_button, 'Edit Item')
      expect(page).to have_selector(:link_or_button, 'Delete Item') if user.privilege_admin?
    end
  end

  def navigate_to_new_item
    @item = FactoryGirl.create(:item)
    visit item_path(@item.id)
    verify_item_fields(@item)
    expect(page).to have_selector(:link_or_button, 'Add to Cart')
  end

  def check_items_index(user)
    visit items_path
    expect(page).to have_current_path items_path
    expect(page).to have_content 'Items'
    expect(page).to have_content 'Advanced Search'
    expect(page).to have_content 'Search items'
    expect(page).to have_content 'Search by model number'
    expect(page).to have_content 'Required tags'
    expect(page).to have_content 'Excluded tags'
    expect(page).to have_selector(:link_or_button, 'Search')

    if user.privilege_admin?
      expect(page).to have_selector(:link_or_button, 'Custom Fields')
      expect(page).to have_selector(:link_or_button, 'New Item')
    elsif user.privilege_manager?
      expect(page).to have_selector(:link_or_button, 'New Item')
      expect(page).not_to have_selector(:link_or_button, 'Custom Fields')
    elsif user.privilege_student?
      expect(page).not_to have_selector(:link_or_button, 'Custom Fields')
      expect(page).not_to have_selector(:link_or_button, 'New Item')
    end
  end
end
