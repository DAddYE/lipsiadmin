require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "should be valid" do
    Account.all.each do |a|
      assert a.valid?
    end
  end
end