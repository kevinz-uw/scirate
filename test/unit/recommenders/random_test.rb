require 'test_helper'
require 'scirate/recommenders/random'


class RecommendersRandomTest < ActiveSupport::TestCase

  def setup
    @article1 = Article.find_by_arxiv_id('0911.5596')
    @article2 = Article.find_by_arxiv_id('1201.4867')

    @rating1 = Rating.new(:article_id => @article1.id,
        :action => RATING_ACTION_SCITE)
  end

  test "doesn't crash" do
    rec = Recommenders::Random.build([@rating1])
    rec.sort_by_scite_odds!([@article1, @article2])
  end

  test "gives different results" do
    rec1 = Recommenders::Random.build([@rating1])
    rec2 = Recommenders::Random.build([@rating1])

    assert_not_equal rec1.scite_odds(@article1), rec1.scite_odds(@article2)
    assert_not_equal rec1.scite_odds(@article1), rec2.scite_odds(@article1)
  end
end
