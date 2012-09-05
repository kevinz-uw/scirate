require 'json'
require 'test_helper'

class InterestsControllerTest < ActionController::TestCase
  def setup
    @user = User.find_by_email('kevinz@cs.washington.edu')
  end

  test "index" do
    get :index, {:format => 'json'}, {:user_id => @user.id}
    assert_response :success
    assert_equal JSON.parse(<<-EOF), JSON.parse(@response.body)
      [{ "category": "quant-ph",
         "id": 92684315,
         "last_seen": "2012-08-17T12:00:00Z",
         "primary": true,
         "user_id": 712064548 },
       { "category": "math.GR",
         "id": 773868689,
         "last_seen": "2012-08-17T12:00:00Z",
         "primary": false,
         "user_id": 712064548 }]
    EOF
  end

  test "create" do
    post :create, {:format => 'json', :category => 'cond-mat',
         :last_seen => DateTime.parse('2012-08-18T12:00:00Z'),
         :primary => 'true'},
        {:user_id => @user.id}
    assert_response :success
    interest = JSON.parse(@response.body)
    assert_equal 'cond-mat', interest['category']
    assert_equal true, interest['primary']
    assert_equal 773868690, interest['id']

    get :index, {:format => 'json'}, {:user_id => @user.id}
    assert_response :success
    assert_equal JSON.parse(<<-EOF), JSON.parse(@response.body)
      [{ "category": "quant-ph",
         "id": 92684315,
         "last_seen": "2012-08-17T12:00:00Z",
         "primary": true,
         "user_id": 712064548 },
       { "category": "math.GR",
         "id": 773868689,
         "last_seen": "2012-08-17T12:00:00Z",
         "primary": false,
         "user_id": 712064548 },
       { "category": "cond-mat",
         "id": #{interest['id']},
         "last_seen": "#{interest['last_seen']}",
         "primary": true,
         "user_id": 712064548 }]
    EOF
  end

  test "update" do
    # TODO
  end

  test "destroy" do
    delete :destroy, {:format => 'json', :id => 773868689},
        {:user_id => @user.id}
    assert_response :success
    assert_equal '{}', @response.body

    get :index, {:format => 'json'}, {:user_id => @user.id}
    assert_response :success
    assert_equal JSON.parse(<<-EOF), JSON.parse(@response.body)
      [{ "category": "quant-ph",
         "id": 92684315,
         "last_seen": "2012-08-17T12:00:00Z",
         "primary": true,
         "user_id": 712064548 }]
    EOF
  end
end
