class AnalyticsController < ApplicationController
  before_filter :check_authorized, :except => :index

  TIMEFRAME_DAYS = {'day' => 1, 'week' => 7, 'month' => 30}
  TIMEFRAME_DESC = {
    'day' => 'Last 24 hours',
    'week' => 'Last 7 days',
    'month' => 'Last 30 days',
  }

  def index
    if !params.include?(:tf)
      redirect_to '/analytics?tf=day'
      return
    end

    @num_users = User.count

    @num_primary_interests = Interest.where(:primary => true).count
    @num_secondary_interests = Interest.where(:primary => false).count

    @num_ratings = Rating.where('action not in (0, 1)').count
    @num_scite_ratings = Rating.where("action = #{RATING_ACTION_SCITE}").count
    @num_arxiv_ratings = Rating.where("action = #{RATING_ACTION_ARXIV}").count
    @num_expand_ratings = Rating.where("action = #{RATING_ACTION_EXPAND}").count
    @num_dislike_ratings =
        Rating.where("action = #{RATING_ACTION_DISLIKE}").count

    @categories = []
    Interest.select(:category).uniq.each do |x|
      primary_count = Interest.where(:category => x.category)
          .where(:primary => true).select(:user_id).count
      secondary_count = Interest.where(:category => x.category)
          .where(:primary => false).select(:user_id).count

      @categories << {
        :name => x.category, 
        :primary_users => primary_count,
        :secondary_users => secondary_count
      }
    end

    @timeframe = params[:tf]
    @timeframe_str = TIMEFRAME_DESC[@timeframe]

    # Only consider events after the given time.
    tf_start = Time.now - TIMEFRAME_DAYS[@timeframe] * 24 * 60 * 60

    @client_load_total = Event.where('at > ?', tf_start)
        .where(:activity => 'client/load').count
    @client_load_users = Event.where('at > ?', tf_start)
        .where(:activity => 'client/load')
        .select(:user_id).uniq.all.length
    @client_settings_total = Event.where('at > ?', tf_start)
        .where(:activity => 'client/settings').count
    @client_settings_users = Event.where('at > ?', tf_start)
        .where(:activity => 'client/settings')
        .select(:user_id).uniq.all.length
    @client_new_total = Event.where('at > ?', tf_start)
        .where(:activity => 'client/new').count
    @client_new_users = Event.where('at > ?', tf_start)
        .where(:activity => 'client/new')
        .select(:user_id).uniq.all.length
    @client_browse_total = Event.where('at > ?', tf_start)
        .where(:activity => 'client/browse').count
    @client_browse_users = Event.where('at > ?', tf_start)
        .where(:activity => 'client/browse')
        .select(:user_id).uniq.all.length

    @client_error_total = Event.where('at > ?', tf_start)
        .where(:activity => 'client/error').count

    @new_total_sum = Integer(Event.joins(:params)
        .where('at > ?', tf_start)
        .where('activity = ?', 'client/new')
        .where('event_params.key = ?', 'total')
        .sum('event_params.int_value'))
    @new_seen_sum = Integer(Event.joins(:params)
        .where('at > ?', tf_start)
        .where('activity = ?', 'client/new')
        .where('event_params.key = ?', 'seen')
        .sum('event_params.int_value'))
    @new_scited_sum = Integer(Event.joins(:params)
        .where('at > ?', tf_start)
        .where('activity = ?', 'client/new')
        .where('event_params.key = ?', 'scited')
        .sum('event_params.int_value'))

    @logins_gp_total = Event.joins(:params)
        .where('at > ?', tf_start)
        .where('event_params.key = ?', 'provider')
        .where('event_params.str_value = ?', 'google_oauth2')
        .count
    @logins_gp_users = Event.joins(:params)
        .where('at > ?', tf_start)
        .where('event_params.key = ?', 'provider')
        .where('event_params.str_value = ?', 'google_oauth2')
        .select(:user_id).uniq.all.length
    @logins_fb_total = Event.joins(:params)
        .where('at > ?', tf_start)
        .where('event_params.key = ?', 'provider')
        .where('event_params.str_value = ?', 'facebook')
        .count
    @logins_fb_users = Event.joins(:params)
        .where('at > ?', tf_start)
        .where('event_params.key = ?', 'provider')
        .where('event_params.str_value = ?', 'facebook')
        .select(:user_id).uniq.all.length

    @tasks_crawl_total = Event.where('at > ?', tf_start)
        .where(:activity => 'task/arxiv/crawl').count
    @tasks_crawl_duration = Event.where('at > ?', tf_start)
        .where(:activity => 'task/arxiv/crawl').average(:duration)
    @tasks_recommender_users_total = Event.where('at > ?', tf_start)
        .where(:activity => 'task/recommender/update_users').count
    @tasks_recommender_users_duration = Event.where('at > ?', tf_start)
        .where(:activity => 'task/recommender/update_users').average(:duration)
    @tasks_recommender_global_total = Event.where('at > ?', tf_start)
        .where(:activity => 'task/recommender/update_global').count
    @tasks_recommender_global_duration = Event.where('at > ?', tf_start)
        .where(:activity => 'task/recommender/update_global').average(:duration)

    @server_home_index_total = Event.where('at > ?', tf_start)
        .where(:activity => 'server/home/index').count
    @server_home_index_users = Event.where('at > ?', tf_start)
        .where(:activity => 'server/home/index')
        .select(:user_id).uniq.all.length
    @server_home_index_duration = Event.where('at > ?', tf_start)
        .where(:activity => 'server/home/index').average(:duration)
    @server_home_welcome_total = Event.where('at > ?', tf_start)
        .where(:activity => 'server/home/welcome').count
    @server_home_welcome_users = Event.where('at > ?', tf_start)
        .where(:activity => 'server/home/welcome')
        .select(:user_id).uniq.all.length
    @server_home_welcome_duration = Event.where('at > ?', tf_start)
        .where(:activity => 'server/home/welcome').average(:duration)
    @server_articles_index_total = Event.where('at > ?', tf_start)
        .where(:activity => 'server/articles/index').count
    @server_articles_index_users = Event.where('at > ?', tf_start)
        .where(:activity => 'server/articles/index')
        .select(:user_id).uniq.all.length
    @server_articles_index_duration = Event.where('at > ?', tf_start)
        .where(:activity => 'server/articles/index').average(:duration)
    @server_interests_index_total = Event.where('at > ?', tf_start)
        .where(:activity => 'server/interests/index').count
    @server_interests_index_users = Event.where('at > ?', tf_start)
        .where(:activity => 'server/interests/index')
        .select(:user_id).uniq.all.length
    @server_interests_index_duration = Event.where('at > ?', tf_start)
        .where(:activity => 'server/interests/index').average(:duration)
    @server_interests_create_total = Event.where('at > ?', tf_start)
        .where(:activity => 'server/interests/create').count
    @server_interests_create_users = Event.where('at > ?', tf_start)
        .where(:activity => 'server/interests/create')
        .select(:user_id).uniq.all.length
    @server_interests_create_duration = Event.where('at > ?', tf_start)
        .where(:activity => 'server/interests/create').average(:duration)
    @server_interests_update_total = Event.where('at > ?', tf_start)
        .where(:activity => 'server/interests/update').count
    @server_interests_update_users = Event.where('at > ?', tf_start)
        .where(:activity => 'server/interests/update')
        .select(:user_id).uniq.all.length
    @server_interests_update_duration = Event.where('at > ?', tf_start)
        .where(:activity => 'server/interests/update').average(:duration)
    @server_interests_destroy_total = Event.where('at > ?', tf_start)
        .where(:activity => 'server/interests/destroy').count
    @server_interests_destroy_users = Event.where('at > ?', tf_start)
        .where(:activity => 'server/interests/destroy')
        .select(:user_id).uniq.all.length
    @server_interests_destroy_duration = Event.where('at > ?', tf_start)
        .where(:activity => 'server/interests/destroy').average(:duration)
    @server_ratings_create_total = Event.where('at > ?', tf_start)
        .where(:activity => 'server/ratings/create').count
    @server_ratings_create_users = Event.where('at > ?', tf_start)
        .where(:activity => 'server/ratings/create')
        .select(:user_id).uniq.all.length
    @server_ratings_create_duration = Event.where('at > ?', tf_start)
        .where(:activity => 'server/ratings/create').average(:duration)
    @server_users_update_total = Event.where('at > ?', tf_start)
        .where(:activity => 'server/users/update').count
    @server_users_update_users = Event.where('at > ?', tf_start)
        .where(:activity => 'server/users/update')
        .select(:user_id).uniq.all.length
    @server_users_update_duration = Event.where('at > ?', tf_start)
        .where(:activity => 'server/users/update').average(:duration)

    render
  end

  def create
    check_param :activity

    if params.include? :duration
      duration = Float(params[:duration])
    else
      duration = nil
    end

    evt_params = {}
    params.each_key do |key|
      if key.start_with? 'str_'
        evt_params[key[4 .. -1]] = params[key]
      elsif key.start_with? 'int_'
        evt_params[key[4 .. -1]] = Integer(params[key])
      elsif key.start_with? 'flt_'
        evt_params[key[4 .. -1]] = Float(params[key])
      end
    end

    Logging::log_event(params[:activity], current_user, duration, evt_params)

    respond_to do |format|
      format.json { render :json => {} }
    end
  end

end
