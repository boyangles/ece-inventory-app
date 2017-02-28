require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @admin = User.new(username: "Austin",
                      privilege: "admin",
                      email: "sample@duke.edu",
                      password: "SamplePass",
                      password_confirmation: "SamplePass",
                      status: "approved",
                      auth_token: Devise.friendly_token)
    @item = items(:item1)
  end

  test "should be valid" do
    assert @admin.valid?
  end

  test "username should be present" do
    @admin.username = ""
    assert_not @admin.valid?
  end

  test "username should not be that long" do
    @admin.username = "q" * 51
    assert_not @admin.valid?
  end

  test "username should be unique" do
    duplicate_user = @admin.dup
    #Testing for case insensitivity
    duplicate_user.username = @admin.username.upcase
    @admin.save
    assert_not duplicate_user.valid?
  end

  test "username should be saved as lower-case" do
    mixed_case_username = "JiMmY"
    @admin.username = mixed_case_username
    @admin.save
    assert_equal mixed_case_username.downcase, @admin.reload.username
  end

  test "email should be present" do
    skip("Ignored until we figure out local account emails")
    @admin.email = ""
    assert_not @admin.valid?
  end

  test "email should not be too long" do
    @admin.email = "te" * 244 + "@sample.com"
    assert_not @admin.valid?
  end

  test "email validation rejects valid addresses that are not duke emails" do
    skip("we don't really have invalid email addresses anymore technically but leaving in case")
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@sample.email.org abc.123@foo.cn austin+andrew@baby.cn]
    valid_addresses.each do |valid_address|
      @admin.email = valid_address
      assert_not @admin.valid?, "#{valid_address.inspect} should have been validated"
    end
  end

  test "email validation accepts duke addresses" do
    valid_addresses = %w[user@cs.duke.edu USER@duke.edu A_US-ER@sample.duke.edu abc.123@ece.cs.duke.edu austin+andrew@edu.duke.edu]
    valid_addresses.each do |valid_address|
      @admin.email = valid_address
      assert @admin.valid?, "#{valid_address.inspect} should have been validated"
    end

  end


  test "email validation rejects invalid emails" do
    skip("Not sure what email addresses are invalid or not at this point? Depends on how we do local accounts")
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @admin.email = invalid_address
      assert_not @admin.valid?, "#{invalid_address.inspect} should have been invalidated"
    end
  end

  test "email should be unique" do
    duplicate_user = @admin.dup
    #Testing ofr case insensitivity
    duplicate_user.email = @admin.email.upcase
    @admin.save
    assert_not duplicate_user.valid?
  end
  
  test "password should be present and non blank" do
    @admin.password = @admin.password_confirmation = " " * 10
    assert_not @admin.valid?
  end

  test "password should have a minimum length of 6" do
    @admin.password = @admin.password_confirmation = "q" * 5
    assert_not @admin.valid?
  end

  test "associated request should be destroyed when user deleted" do
    skip "we don't delete users anymore"
    @admin.save!

    Request.create!(
      reason: 'For test',
      status: 'outstanding',
      request_type: 'disbursement',
      user_id: @admin.id)

    # One for cart, one for normal request
    assert_difference ['Request.count'], -2 do
      @admin.deactivate
    end
  end

  test "verify before_create makes auth_token unique" do
    duplicate_user = @admin.dup
    duplicate_user[:username] = 'AustinDup'
    duplicate_user[:email] = 'sampledup@duke.edu'

    duplicate_user[:auth_token] = @admin[:auth_token]
    @admin.save

    assert duplicate_user.valid?
  end
end
