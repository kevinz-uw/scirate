require 'json'
require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = User.find_by_email('kevinz@cs.washington.edu')
  end

  test "update" do
    put :update, {:format => 'json', :name => 'Kevin C. Zatloukal'},
        {:user_id => @user.id}
    assert_response :success
    assert_equal JSON.parse('{}'), JSON.parse(@response.body)

    @user = User.find_by_email('kevinz@cs.washington.edu')
    assert_equal 'Kevin C. Zatloukal', @user.name
  end
end
