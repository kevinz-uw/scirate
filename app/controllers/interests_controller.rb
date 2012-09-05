require 'scirate/logging'
require 'scirate/updates'

class InterestsController < ApplicationController
  before_filter :check_authorized

  def index
    start_time = Time.now

    interests = Interest.where(:user_id => @current_user.id)

    respond_to do |format|
      format.json { render :json => interests }
    end

    end_time = Time.now
    Logging::log_event('server/interests/index', current_user,
        end_time - start_time, {})
  end

  def create
    start_time = Time.now

    check_param :category
    check_param :primary

    interest = Interest.new
    interest.user_id = @current_user.id
    interest.category = params[:category]
    interest.primary = (params[:primary] == 'true')
    # Start out assuming all of the last crawl is new.
    if Crawl.count >= 2
      interest.last_seen = Crawl.order('finished DESC')[1].finished \
          .advance(:minutes => 1)
    else
      interest.last_seen = DateTime.parse('2000-01-01T00:00:00')
    end
    interest.save!

    respond_to do |format|
      format.json { render :json => Updates::interest_with_updates(interest) }
    end

    end_time = Time.now
    Logging::log_event('server/interests/create', current_user,
        end_time - start_time, {})
  end

  def update
    start_time = Time.now

    check_param :id

    interest = Interest.find(params[:id].to_i)

    # If the user is setting last_seen, then mark all old articles as seen.
    if params.include? :last_seen
      Updates::updates_for(interest).each do |article|
        rating = Rating.where(:article_id => article.id) \
                       .where(:user_id => @current_user.id) \
                       .first
        if !rating
          rating = Rating.new
          rating.user_id = @current_user.id
          rating.article_id = article.id
          rating.action = 0
          rating.save!
        end
      end
    end

    # Update the value of this interest.
    if params.include? :category
      interest.category = params[:category]
    end
    if params.include? :primary
      interest.primary = !!params[:primary]
    end
    if params.include? :last_seen
      interest.last_seen = DateTime.now  # can only update to right now
    end
    interest.save!

    respond_to do |format|
      format.json { render :json => Updates::interest_with_updates(interest) }
    end

    end_time = Time.now
    Logging::log_event('server/interests/update', current_user,
        end_time - start_time, {})
  end

  def destroy
    start_time = Time.now

    check_param :id

    interest = Interest.find(params[:id].to_i)
    interest.destroy

    respond_to do |format|
      format.json { render :json => interest.errors }
    end

    end_time = Time.now
    Logging::log_event('server/interests/destroy', current_user,
        end_time - start_time, {})
  end
end
