require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    @user = User.new(username: "Austin", privilege: "regular", password: "SimplePass")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "username should be present" do
    @user.username = ""
    assert_not @user.valid?
  end

  test "password should be present" do
    @user.password = ""
    assert_not @user.valid?
  end

  test "username should not be that long" do
    @user.username = "q" * 51
    assert_not @user.valid?
  end

  test "username should be unique" do
    duplicate_user = @user.dup
    #Testing ofr case insensitivity
    duplicate_user.username = @user.username.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "username should be saved as lower-case" do
    mixed_case_username = "JiMmY"
    @user.username = mixed_case_username
    @user.save
    assert_equal mixed_case_username.downcase, @user.reload.username
  end
end
