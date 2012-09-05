require 'test_helper'
require 'scirate/recommenders/naive_bayes'


class RecommendersNaiveBayesTest < ActiveSupport::TestCase

  def setup
    @article1 = Article.find_by_arxiv_id('0911.5596')
    @article2 = Article.find_by_arxiv_id('1201.4867')

    rating1 = Rating.new(:article_id => @article1.id,
        :action => RATING_ACTION_SCITE)
    rating2 = Rating.new(:article_id => @article2.id,
        :action => RATING_ACTION_SEEN)
    @rec = Recommenders::NaiveBayes.build([rating1, rating2])
  end

  test "doesn't crash" do
    @rec.sort_by_scite_odds!([@article1, @article2])
  end

  test "predicts higher for scited" do
    assert_operator @rec.scite_odds(@article1), :>, @rec.scite_odds(@article2)
  end
end
