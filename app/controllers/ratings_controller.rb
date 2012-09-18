require 'scirate/logging'

class RatingsController < ApplicationController
  before_filter :check_authorized

  def create
    start_time = Time.now

    check_param :article_id
    check_param :rating_action

    action = params[:rating_action].to_i
    rating = Rating.where(
        :user_id => @current_user.id,
        :article_id => params[:article_id].to_i).first
    new_action = RatingsController.update_action(rating, action)

    # update the scite count
    if rating
      article = Article.find(params[:article_id].to_i)
      if (rating.action == RATING_ACTION_SCITE) and
         (new_action != RATING_ACTION_SCITE)
        if article.scites != nil  # this should always be true
          article.scites -= 1
          article.save!
        end
      end
      if (rating.action != RATING_ACTION_SCITE) and
         (new_action == RATING_ACTION_SCITE)
        article.scites = (article.scites ? article.scites : 0) + 1
        article.save!
      end
    elsif new_action == RATING_ACTION_SCITE
      article = Article.find(params[:article_id].to_i)
      article.scites = (article.scites ? article.scites : 0) + 1
      article.save!
    end

    # update the current rating
    if rating
      rating.action = new_action
    else
      rating = Rating.new
      rating.user_id = @current_user.id
      rating.article_id = params[:article_id]
      rating.action = new_action
    end
    rating.save!

    respond_to do |format|
      format.json { render :json => rating }
    end

    end_time = Time.now
    Logging::log_event('server/ratings/create', current_user,
        end_time - start_time, {})
  end

  # Returns the new action after receiving the given update for this rating.
  # The rules only allow the number to (1) get larger (2) go from the maximum
  # back to zero or (3) change sign
  def self.update_action(rating, action)
    if rating == nil
      return action
    elsif action.abs >= rating.action.abs
      return action
    elsif (action == 0) and (rating.action == RATING_ACTION_MAXIMUM)
      return action
    else
      return rating.action
    end
  end
end
