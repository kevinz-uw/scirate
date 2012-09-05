require 'test_helper'
require 'scirate/keyword'


class KeywordTest < ActiveSupport::TestCase

  test "tokenize" do
    assert_equal Keyword::tokenize('this is  some \n stuff'),
        ['some', 'stuff']
    assert_equal Keyword::tokenize('This is (some) STUFF!'),
        ['some', 'stuff']
    assert_equal Keyword::tokenize(
        'H-Y.Yang, A.F. Albuquerque, S. Capponi, ' +
        'A.M. Lauchli, and K.P. Schmidt'),
        ['yang', 'albuquerque', 'capponi', 'lauchli', 'schmidt']
    assert_equal Keyword::tokenize(
        'Andrew M. Childs, John Preskill, and Joseph Renes (Caltech)'),
        ['andrew', 'childs', 'john', 'preskill', 'joseph', 'renes', 'caltech']
  end

  test "find keywords" do
    kw_exp = {
      "give" => 3, "brief" => 3, "technical" => 3, "introduction" => 3,
      "spin" => 2, "systems" => 2, "computational" => 2, "complexity" => 2,
      "daniel" => 1, "gottesman" => 1, "perimeter" => 1, "institute" => 1
    }
    kw_act = Keyword::all_from(Article.find_by_arxiv_id('0911.5596'))
    assert_equal kw_exp.length, kw_act.length
    kw_act.each do |keyword|
      assert_equal [keyword.word, keyword.location],
          [keyword.word, kw_exp[keyword.word]]
    end
  end
end
