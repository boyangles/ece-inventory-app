require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.new(username: "Austin", privilege: "admin", email: "sample@cs.duke.edu",
                     password: "SamplePass", password_confirmation: "SamplePass", status: "approved")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "username should be present" do
    @user.username = ""
    assert_not @user.valid?
  end

  test "username should not be that long" do
    @user.username = "q" * 51
    assert_not @user.valid?
  end

  test "username should be unique" do
    duplicate_user = @user.dup
    #Testing for case insensitivity
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

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "te" * 244 + "@sample.com"
    assert_not @user.valid?
  end

  test "email validation rejects valid addresses that are not duke emails" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@sample.email.org abc.123@foo.cn austin+andrew@baby.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert_not @user.valid?, "#{valid_address.inspect} should have been validated"
    end
  end

  test "email validation accepts duke addresses" do
    valid_addresses = %w[user@cs.duke.edu USER@duke.edu A_US-ER@sample.duke.edu abc.123@ece.cs.duke.edu austin+andrew@edu.duke.edu]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should have been validated"
    end

  end

  test "email validation rejects invalid emails" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should have been invalidated"
    end
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    #Testing ofr case insensitivity
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "password should be present and non blank" do
    @user.password = @user.password_confirmation = " " * 10
    assert_not @user.valid?
  end

  test "password should have a minimum length of 6" do
    @user.password = @user.password_confirmation = "q" * 5
    assert_not @user.valid?
  end
end
