require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(username: 'user_requesttest',
                         email: 'user_requesttest@example.com',
                         privilege: 'admin',
                         status: 'approved',
                         password: 'password',
                         password_confirmation: 'password')
    @request = Request.new(
      reason: 'For test',
      status: 'outstanding',
      request_type: 'disbursement',
      user_id: @user.id)
  end

  test "should be valid" do
    assert @request.valid?
  end

  test "user id should be present" do
    @request.user_id = nil
    assert_not @request.valid?
  end

  test "there cannot be two 'cart' request for a single user at any time" do
    @prev_request = Request.where(:user_id => @user.id).where(:status => :cart).first
    @request1 = Request.new(reason: 'test1', status: 'cart',
                            request_type: 'disbursement',
                            user_id: @prev_request[:user_id])
    assert_not @request1.valid?
  end
end
