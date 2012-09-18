require 'json'
require 'test_helper'

class ArticlesControllerTest < ActionController::TestCase
  def setup
    @user = User.find_by_email('kevinz@cs.washington.edu')
  end

  test "simple" do
    get :index, {:format => 'json', :category => 'quant-ph',
         :since => '2000-01-01 00:00:00 UTC', :offset => 0, :limit => 10},
        {:user_id => @user.id}
    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 2, results.length
    assert_equal '1201.4867', results[0]['arxiv_id']
    assert_equal '0911.5596', results[1]['arxiv_id']
  end

  test "category" do
    get :index, {:format => 'json', :category => 'cond-mat',
         :since => '2000-01-01 00:00:00 UTC', :offset => 0, :limit => 10},
        {:user_id => @user.id}
    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 0, results.length
  end

  test "since" do
    get :index, {:format => 'json', :category => 'quant-ph',
         :since => '2009-11-30 12:00:00 UTC', :offset => 0, :limit => 10},
        {:user_id => @user.id}
    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 1, results.length
    assert_equal '1201.4867', results[0]['arxiv_id']

    get :index, {:format => 'json', :category => 'quant-ph',
         :since => '2012-01-23 12:00:00 UTC', :offset => 0, :limit => 10},
        {:user_id => @user.id}
    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 0, results.length
  end

  test "until" do
    get :index, {:format => 'json', :category => 'quant-ph',
         :since => '2000-01-01 12:00:00 UTC',
         :until => '2012-01-23 12:00:00 UTC', :offset => 0, :limit => 10},
        {:user_id => @user.id}
    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 2, results.length
    assert_equal '1201.4867', results[0]['arxiv_id']
    assert_equal '0911.5596', results[1]['arxiv_id']

    get :index, {:format => 'json', :category => 'quant-ph',
         :since => '2000-01-01 12:00:00 UTC',
         :until => '2009-11-30 12:00:00 UTC', :offset => 0, :limit => 10},
        {:user_id => @user.id}
    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 1, results.length
    assert_equal '0911.5596', results[0]['arxiv_id']

    get :index, {:format => 'json', :category => 'quant-ph',
         :since => '2000-01-01 12:00:00 UTC',
         :until => '2000-01-01 12:00:00 UTC', :offset => 0, :limit => 10},
        {:user_id => @user.id}
    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 0, results.length
  end

  test "updates" do
    article1 = Article.find_by_arxiv_id('0911.5596')
    article2 = Article.find_by_arxiv_id('1201.4867')

    ratings = [
        Rating.new(:article_id => article1.id, :action => RATING_ACTION_SEEN),
        Rating.new(:article_id => article2.id, :action => RATING_ACTION_SCITE)
      ]
    rec = Recommenders::build('naive bayes', ratings)

    interest =
        Interest.where(:user_id => @user.id, :category => 'quant-ph').first
    interest.model = rec.to_model
    interest.save!

    get :index, {:format => 'json', :category => 'quant-ph',
         :since => '2000-01-01 00:00:00 UTC', :updates => 1,
         :offset => 0, :limit => 10},
        {:user_id => @user.id}
    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 2, results.length
    assert_equal '1201.4867', results[0]['arxiv_id']
    assert_equal '0911.5596', results[1]['arxiv_id']
  end

  test "scited" do
    article = Article.find_by_arxiv_id('1201.4867')

    get :index, {:format => 'json', :category => 'quant-ph',
         :since => '2009-11-30 12:00:00 UTC', :offset => 0, :limit => 10},
        {:user_id => @user.id}
    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 1, results.length
    assert_equal article.arxiv_id, results[0]['arxiv_id']
    assert_equal false, results[0]['scited']

    rating = Rating.where(:user_id => @user.id, :article_id => article.id)
                   .first!
    rating.action = 4
    rating.save!

    get :index, {:format => 'json', :category => 'quant-ph',
         :since => '2009-11-30 12:00:00 UTC', :offset => 0, :limit => 10},
        {:user_id => @user.id}
    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 1, results.length
    assert_equal article.arxiv_id, results[0]['arxiv_id']
    assert_equal true, results[0]['scited']
  end
end
