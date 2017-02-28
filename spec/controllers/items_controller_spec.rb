require 'support/spec_test_helper.rb'

RSpec.describe "Item Controller Tests", :type => :feature do

  describe "GET index" do
    it "gets all items as admin and checks New Item option is listed" do
      login(:user_admin)
      check_items_index('admin')
    end

    it "gets all items as manager" do
      login(:user_manager)
      check_items_index('manager')
    end

    it "gets all items as student" do
      login(:user_student)
      check_items_index('student')
    end
  end

  describe "GET show" do
    it "gets a specific item and displays info as admin" do
      login(:user_admin)
      navigate_to_new_item
    end

    it "gets a specific item and displays info as manager" do
      login(:user_manager)
      navigate_to_new_item
    end

    it "gets a specific item and displays info as student" do
      login(:user_student)
      navigate_to_new_item
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
      find_link('Edit Item Details').click
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

    it "can update item except quantity as manager" do
      login(:user_manager)
      navigate_to_new_item
      find_link('Edit Item Details').click
      expect(page).to have_no_content('Quantity')
      updated_name = Faker::Name.name
      fill_in('Name', with: updated_name)
      find_button('Submit').click
      updated_item = Item.find_by(unique_name: updated_name)
      expect(page).to have_current_path item_path(updated_item.id)
      verify_item_fields(updated_item)
    end

    it "can update quantity as admin" do
      login(:user_admin)
      navigate_to_new_item
      find_link('Log Acquisition or Destruction/Correct Quantity').click
      expect(page).to have_content('New Quantity')
      fill_in('Quantity', with: 333)
      find_button('Update Item').click
      updated_item = Item.find_by(unique_name: @item.unique_name)
      expect(page).to have_current_path item_path(updated_item.id)
      verify_item_fields(updated_item)
    end

    it "cannot update item as student" do
      login(:user_student)
      navigate_to_new_item
      expect(page).not_to have_selector(:link_or_button, 'Edit Item Details')
      visit edit_item_path(@item.id)
      expect(page).to have_content 'You do not have permission to perform this operation'
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
    expect(page).to have_content 'Name'
    expect(page).to have_content 'Description'
    expect(page).to have_content 'Model Number'
    expect(page).to have_content 'Tags'
    expect(page).to have_content 'Associated Tags'
  end

  def fill_in_new_item_fields(name)
    fill_in('Name', with: name)
    fill_in('Quantity', with: 3)
    fill_in('Description', with: 'A nice description')
    fill_in('Model Number', with: 'Ab123')
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

  def navigate_to_new_item
    @item = FactoryGirl.create(:item)
    visit item_path(@item.id)
    verify_item_fields(@item)
    expect(page).to have_content 'Tags'
    expect(page).to have_selector(:link_or_button, 'Add to Cart')
  end

  def check_items_index(user)
    visit items_path
    expect(page).to have_current_path items_path
    expect(page).to have_content 'Items'
    expect(page).to have_content 'Search by item name'
    expect(page).to have_content 'Search by model number'
    expect(page).to have_content 'Required Tags'
    expect(page).to have_content 'Excluded Tags'
    expect(page).to have_selector(:link_or_button, 'Search')

    if user == 'admin'
      expect(page).to have_selector(:link_or_button, 'Custom Fields')
      expect(page).to have_selector(:link_or_button, 'New Item')
    elsif user == 'manager'
      expect(page).to have_selector(:link_or_button, 'New Item')
      expect(page).not_to have_selector(:link_or_button, 'Custom Fields')
    elsif user == 'student'
      expect(page).not_to have_selector(:link_or_button, 'Custom Fields')
      expect(page).not_to have_selector(:link_or_button, 'New Item')
    end
  end
end
