require 'scirate/logging'

class RatingsController < ApplicationController
  before_filter :check_authorized

  def create
    start_time = Time.now

    check_param :article_id
    check_param :rating_action

    rating = Rating.where(
        :user_id => @current_user.id,
        :article_id => params[:article_id]).first
    if rating
      action = params[:rating_action].to_i
      if action < 0
        rating.action = action
      elsif rating.action >= 0
        rating.action = [rating.action, action].max
      elsif action == RATING_ACTION_SCITE
        rating.action = action
      end
    else
      rating = Rating.new
      rating.user_id = @current_user.id
      rating.article_id = params[:article_id]
      rating.action = params[:rating_action].to_i
    end
    rating.save

    respond_to do |format|
      format.json { render :json => rating }
    end

    end_time = Time.now
    Logging::log_event('server/ratings/create', current_user,
        end_time - start_time, {})
  end
end
