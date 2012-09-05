require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  def setup
    @user = User.find_by_email('kevinz@cs.washington.edu')
  end

  test "unauthenticated" do
    get :index
    assert_response :success
    assert_select 'A', 'Google'
    assert_select 'A', 'Facebook'
  end

  test "authenticated" do
    get :index, {}, {:user_id => @user.id}
    assert_response :success
    scripts = assert_select 'script'
    assert_equal scripts.length, 2
    assert scripts[0].children[0].content.index('kevinz@cs.washington.edu') >= 0
    assert scripts[1]['src'].index('client.js') >= 0
  end
end
