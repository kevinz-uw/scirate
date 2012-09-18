require 'json'
require 'test_helper'

class RatingsControllerTest < ActionController::TestCase
  def setup
    @user = User.find_by_email('kevinz@cs.washington.edu')
    @article1 = Article.find_by_arxiv_id('0911.5596')
    @article2 = Article.find_by_arxiv_id('1201.4867')
  end

  test "create" do
    post :create, {:format => 'json',
         :article_id => @article1.id, :rating_action => 4},
        {:user_id => @user.id}
    assert_response :success
    assert_equal JSON.parse(<<-EOF), JSON.parse(@response.body)
      { "action": 4,
        "article_id": 980190962,
        "id": 599112458,
        "user_id": 712064548 }
    EOF
  end

  test "update action" do
    # Test that we can change from 3 to 4, not from 4 to 3, but from 4 to -1.

    @rating = \
        Rating.where(:user_id => @user.id, :article_id => @article2.id).first
    assert_equal 3, @rating.action

    post :create, {:format => 'json',
         :article_id => @article2.id, :rating_action => 4},
        {:user_id => @user.id}
    assert_response :success
    assert_equal JSON.parse(<<-EOF), JSON.parse(@response.body)
      { "action": 4,
        "article_id": 298486374,
        "id": 599112457,
        "user_id": 712064548 }
    EOF

    @rating = \
        Rating.where(:user_id => @user.id, :article_id => @article2.id).first
    assert_equal 4, @rating.action

    post :create, {:format => 'json',
         :article_id => @article2.id, :rating_action => 2},
        {:user_id => @user.id}
    assert_response :success
    assert_equal JSON.parse(<<-EOF), JSON.parse(@response.body)
      { "action": 4,
        "article_id": 298486374,
        "id": 599112457,
        "user_id": 712064548 }
    EOF

    @rating = \
        Rating.where(:user_id => @user.id, :article_id => @article2.id).first
    assert_equal 4, @rating.action

    post :create, {:format => 'json',
         :article_id => @article2.id, :rating_action => -4},
        {:user_id => @user.id}
    assert_response :success
    assert_equal JSON.parse(<<-EOF), JSON.parse(@response.body)
      { "action": -4,
        "article_id": 298486374,
        "id": 599112457,
        "user_id": 712064548 }
    EOF

    @rating = \
        Rating.where(:user_id => @user.id, :article_id => @article2.id).first
    assert_equal -4, @rating.action
  end

  test "update scites count" do
    assert_equal 0, @article2.scites

    post :create, {:format => 'json',
         :article_id => @article2.id, :rating_action => 4},
        {:user_id => @user.id}
    assert_response :success

    @article2 = Article.find_by_arxiv_id('1201.4867')
    assert_equal 1, @article2.scites

    post :create, {:format => 'json',
         :article_id => @article2.id, :rating_action => 0},
        {:user_id => @user.id}
    assert_response :success

    @article2 = Article.find_by_arxiv_id('1201.4867')
    assert_equal 0, @article2.scites

    post :create, {:format => 'json',
         :article_id => @article2.id, :rating_action => 3},
        {:user_id => @user.id}
    assert_response :success

    @article2 = Article.find_by_arxiv_id('1201.4867')
    assert_equal 0, @article2.scites

    post :create, {:format => 'json',
         :article_id => @article2.id, :rating_action => -4},
        {:user_id => @user.id}
    assert_response :success

    @article2 = Article.find_by_arxiv_id('1201.4867')
    assert_equal 0, @article2.scites

    post :create, {:format => 'json',
         :article_id => @article2.id, :rating_action => 4},
        {:user_id => @user.id}
    assert_response :success

    @article2 = Article.find_by_arxiv_id('1201.4867')
    assert_equal 1, @article2.scites

    post :create, {:format => 'json',
         :article_id => @article2.id, :rating_action => -4},
        {:user_id => @user.id}
    assert_response :success

    @article2 = Article.find_by_arxiv_id('1201.4867')
    assert_equal 0, @article2.scites

    # Now repeat the initial steps above when there is no current rating.
    assert_equal 0, @article1.scites

    post :create, {:format => 'json',
         :article_id => @article1.id, :rating_action => 4},
        {:user_id => @user.id}
    assert_response :success

    @article1 = Article.find_by_arxiv_id('0911.5596')
    assert_equal 1, @article1.scites

    post :create, {:format => 'json',
         :article_id => @article1.id, :rating_action => 0},
        {:user_id => @user.id}
    assert_response :success

    @article1 = Article.find_by_arxiv_id('0911.5596')
    assert_equal 0, @article1.scites
  end
end
