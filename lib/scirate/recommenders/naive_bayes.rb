require 'set'
require 'scirate/keyword'
require 'scirate/recommenders/recommender'


module Recommenders

  # TODO: Weight actions that are positive as fractions of a site.
  # TODO: Use a better Laplace smoothing function.
  class NaiveBayes < Recommender
    METHOD = 'naive bayes'

    def self.build(ratings)
      if ratings.length == 0
        return NaiveBayes.new({})
      end
  
      article_scited = {}
      ratings.each do |r|
        article_scited[r.article_id] = (r.action == RATING_ACTION_SCITE)
      end
  
      # Determine the overall frequency of sciting.
      scite_count = noscite_count = 0
      article_scited.each do |a, v|
        if v
          scite_count += 1
        else
          noscite_count += 1
        end
      end

      # Determine the per-word frequency of sciting.
      words = Set.new
      word_scite_count = {}
      word_noscite_count = {}
      article_scited.each do |aid, scited|
        article = Article.find(aid)
        Keyword.all_from(article).each do |kw|
          if not words.include?(kw.word)
            words.add(kw.word)
            word_scite_count[kw.word] = 0
            word_noscite_count[kw.word] = 0
          end
          if scited
            word_scite_count[kw.word] += 1
          else
            word_noscite_count[kw.word] += 1
          end
        end
      end
  
      # Return a description of this model.
      params = {'__prior__' => log_odds(scite_count, noscite_count)}
      words.each do |w|
        params[w] = log_odds(word_scite_count[w], word_noscite_count[w])
      end
      return NaiveBayes.new(params)
    end

    # Returns the log-odds ratio of sciting this article.
    def scite_odds(article)
      s = @params['__prior__']
      Keyword.all_from(article).each do |k|
        if @params.include? k.word
          s += @params[k.word]
        else
          s += NaiveBayes.log_odds(0, 0)
        end
      end
      return s
    end

    def initialize(params)
      super(METHOD, params)
    end

    private
    def self.log_odds(true_count, false_count)
      return Math.log(Float(true_count + 1) / Float(false_count + 2))
    end
  end
end
