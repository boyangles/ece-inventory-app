require 'test_helper'

class LogTest < ActiveSupport::TestCase
  def setup
    @admin = users(:bernard)
    @item = items(:item1)

    @log = Log.new(
      log_type: 0,
      user_id: @admin.id
    )
  end

  test "should be valid" do
    assert @log.valid?
  end

  test "order should be most recent first" do
    assert_equal logs(:most_recent), Log.first
  end
end
