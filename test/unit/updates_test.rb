require 'test_helper'
require 'scirate/updates'

class UpdatesTest < ActiveSupport::TestCase
  test "interests with updates" do
    user = User.find_by_email('kevinz@cs.washington.edu')
    assert_equal Updates.interests_with_updates(user),
      [{ :id => 92684315,
         :category => 'quant-ph',
         :primary => true,
         :last_seen => DateTime.parse('2012-08-17T12:00:00Z'),
         :new_since => DateTime.parse('2012-01-23T12:00:00Z'),
         :new_count => 0 },
       { :id => 773868689, :category => 'math.GR', :primary => false }]
  end
end
