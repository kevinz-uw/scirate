module Recommenders
  # Base class for recommendation methods. Each must have a unique name, called
  # 'method' below. The parameters of the method are stored in the model hash.
  class Recommender
    attr_accessor :method

    # Returns a database Model class describing this recommender.
    # NOTE: interest_id must be set before this can be saved.
    def to_model
      model = Model.new(:method => @method)
      model.params = []
      @params.each do |key, value|
        model.params << ModelParam.new(:key => key, :value => value)
      end
      return model
    end

    # Returns a numeric prediction that should correlate with sciting.
    def scite_odds(article)
      raise Exception, 'scite_odds not implemented'
    end

    # Sorts the given array (in place!) by the scite odds.
    def sort_by_scite_odds!(articles)
      odds = {}
      articles.each do |article|
        odds[article.id] = scite_odds(article)
      end

      articles.sort_by! {|a| -odds[a.id]}
    end

    # Called from a subclass to initialize this model.
    private
    def initialize(method, params)
      @method = method
      @params = params
    end
  end
end
