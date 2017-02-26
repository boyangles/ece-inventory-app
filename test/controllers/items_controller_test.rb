require 'test_helper'

class ItemsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @admin = users(:bernard)
    @student1 = users(:alex)
  end

  test "go to home page instead of items page if not logged in" do
    get items_path
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # test "go to items page if logged in" do
  #   log_in_as(@user2)
  #   get items_path
  #   assert flash.empty?
  #   assert_redirected_to items_path
  # end

  test "try to create item as non_admin - should be impossible " do

  end

  test "create item as admin" do

  end

  test "show item as non_admin - should be impossible" do

  end

  test "show item as admin  " do

  end

  test "edit item as non_admin - should be impossible" do

  end

  test "edit item as admin" do

  end

  test "delete item as non_admin - should be impossible " do

  end

  test "delete item as admin" do

  end


end
