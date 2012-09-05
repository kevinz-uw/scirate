require 'set'
require 'scirate/recommenders/recommender'


module Recommenders

  class Random < Recommender
    METHOD = 'random'

    def self.build(ratings)
      params = {}
      params['seed'] = (0...8).map {65.+(rand(25)).chr}.join
      return Random.new(params)
    end

    def scite_odds(article)
      return Math.log(1 + (@params['seed'] + article.arxiv_id).hash.abs)
    end

    def initialize(params)
      super(METHOD, params)
    end
  end
end
