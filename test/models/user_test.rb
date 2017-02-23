require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.new(username: "Austin",
                     privilege: "admin",
                     email: "sample@duke.edu",
                     password: "SamplePass",
                     password_confirmation: "SamplePass",
                     status: "approved",
                     auth_token: Devise.friendly_token)
    @item = items(:item1)
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
    skip("Ignored until we figure out local account emails")
    @user.email = ""
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "te" * 244 + "@sample.com"
    assert_not @user.valid?
  end

  test "email validation rejects valid addresses that are not duke emails" do
    skip("we don't really have invalid email addresses anymore technically but leaving in case")
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
    skip("Not sure what email addresses are invalid or not at this point? Depends on how we do local accounts")
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

  test "associated request should be destroyed when user deleted" do
    @user.save!

    Request.create!(
      reason: 'For test',
      status: 'outstanding',
      request_type: 'disbursement',
      user_id: @user.id)

    # One for cart, one for normal request
    assert_difference ['Request.count'], -2 do
      @user.destroy!
    end
  end

  test "verify before_create makes auth_token unique" do
    duplicate_user = @user.dup
    duplicate_user[:username] = 'AustinDup'
    duplicate_user[:email] = 'sampledup@duke.edu'

    duplicate_user[:auth_token] = @user[:auth_token]
    @user.save

    assert duplicate_user.valid?
  end
end
