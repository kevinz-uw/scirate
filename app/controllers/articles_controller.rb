require 'scirate/logging'

class ArticlesController < ApplicationController
  before_filter :check_authorized

  def index
    start_time = Time.now

    check_param :category

    # Find the articles in this category in the date range (since, until].
    articles = Article.joins(:categories)
    articles = articles.where('categories.name = ?', params[:category])
    if params.include? :since
      articles = articles.where('articles.published >= ?',
          DateTime.parse(params[:since]) + 1.second)
    end
    if params.include? :until
      articles = articles.where('articles.published <= ?',
          DateTime.parse(params[:until]) + 1.second)
    end

    # If these are updates, then sort them using the model.
    if params.include? :updates
      articles = articles.order('published ASC')
      articles = articles.all

      interest = Interest.where(
          :user_id => @current_user.id, :category => params[:category]).first
      if interest and interest.model
        recommender = Recommenders::load(interest.model)
        recommender.sort_by_scite_odds!(articles)
      end

    # Otherwise, order them using the global scites count.
    else
      check_param :limit
      check_param :offset

      articles = articles.limit([Integer(params[:limit]), 100].min)
      articles = articles.offset(Integer(params[:offset]))
      articles = articles.order('scites DESC, published DESC')
      articles = articles.all
    end

    respond_to do |format|
      format.json { render :json => articles.to_json(
        :include => { :authors => { :only => [:name, :institution] } },
        :user => current_user,
      ) }
    end

    end_time = Time.now
    Logging::log_event('server/articles/index', current_user,
        end_time - start_time, {})
  end
end
