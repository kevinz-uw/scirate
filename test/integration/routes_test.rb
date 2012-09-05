require 'test_helper'

class RoutesTest < ActionController::IntegrationTest
  test "routes" do
    assert_generates '/', :controller => 'home', :action => 'index'

    assert_generates '/signout', :controller => 'sessions', :action => 'destroy'
    assert_generates '/auth/google_oauth2/callback', :controller => 'sessions',
        :action => 'create', :provider => 'google_oauth2'
    assert_generates '/auth/facebook/callback', :controller => 'sessions',
        :action => 'create', :provider => 'facebook'

    assert_generates '/interests',
        {:controller => 'interests', :action => 'index'}
    assert_generates '/interests',
        {:controller => 'interests', :action => 'create'},
        {:method => :post}
    assert_generates '/interests/12',
        {:controller => 'interests', :action => 'update', :id => 12},
        {:method => :put}
    assert_generates '/interests/12',
        {:controller => 'interests', :action => 'destroy', :id => 12},
        {:method => :delete}

    assert_generates '/ratings',
        {:controller => 'ratings', :action => 'create'},
        {:method => :post}
  end
end
