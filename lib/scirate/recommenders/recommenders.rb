require 'scirate/recommenders/random'
require 'scirate/recommenders/naive_bayes'


module Recommenders
  # Builds and returns a recommender of the given type from the given data.
  def self.build(method, ratings)
    if method == Random::METHOD
      return Random.build(ratings)
    elsif method == NaiveBayes::METHOD
      return NaiveBayes.build(ratings)
    else
      raise Exception, 'unknown recommendation method: #{method}'
    end
  end

  # Returns the recommender stored in the given model.
  def self.load(model)
    if model.method == Random::METHOD
      return Random.new(params_from_model(model))
    elsif model.method == NaiveBayes::METHOD
      return NaiveBayes.new(params_from_model(model))
    else
      raise Exception, 'unknown recommendation method: #{method}'
    end
  end

  # Returns the params encoded in the given model.
  private
  def self.params_from_model(model)
    params = {}
    model.params.each do |param|
      params[param.key] = param.value
    end
    return params
  end

  # Updates all of the models for users in the database with ratings.
  def self.update_user_models
    count = 0
    User.all.each do |user|
      if user.ratings.length > 0
        count += 1
        user.interests.each do |interest|
          if interest.primary
            interest_ratings = category_ratings(interest.category, user.ratings)
            interest.model =
                Recommenders::build('naive bayes', interest_ratings).to_model
            interest.save!
          end
        end
      end
    end
    $stderr.puts "Updated models for #{count} of #{User.count} users."
  end

  private
  def self.category_ratings(cat_name, ratings)
    return ratings.select {|r|
        in_category(cat_name, Article.find(r.article_id)) }
  end

  private
  def self.in_category(cat_name, article)
    article.categories.each do |cat|
      return true if cat.name == cat_name
    end
    return false
  end

  # Updates the global model shared by all users.
  def self.update_global_model
    User  # force Rating to load

    has_scites = Set.new
    Article.where('scites > 0').each do |article|
      has_scites.add(article.id)
    end

    needs_scites = Set.new
    Article.joins('JOIN Ratings ON Ratings.article_id = Articles.id')
           .where('Ratings.action = ?', RATING_ACTION_SCITE)
           .uniq
           .each do |article|
      needs_scites.add(article.id)
    end

    # Update the scite count of every scited article.
    needs_scites.each do |id|
      article = Article.find(id)
      article.scites =
          Rating.where(:article_id => article.id)
                .where(:action => RATING_ACTION_SCITE)
                .count
      article.save!
    end
    $stderr.puts "Updated scite count for #{needs_scites.size} articles."

    # Clear out old scite counts.
    has_scites.subtract(needs_scites)
    has_scites.each do |id|
      article = Article.find(id)
      article.scites = 0
      article.save!
    end
    $stderr.puts "Removed scite count for #{has_scites.size} articles."
  end
end
