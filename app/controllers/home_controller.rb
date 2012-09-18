require 'scirate/logging'
require 'scirate/updates'

class HomeController < ApplicationController
  def index
    start_time = Time.now

    if user_signed_in
      @interests = Updates::interests_with_updates(current_user)
      @max_published = Crawl.maximum(:max_published);
      render # index
    else
      @auth_url_google = '/auth/google_oauth2'
      if ENV.include? 'GOOGLE_HTTPS'
        @auth_url_google =
            "https://#{request.host_with_port}#{@auth_url_google}"
      end
      @auth_url_facebook = '/auth/facebook'
      if ENV.include? 'FACEBOOK_HTTPS'
        @auth_url_facebook =
            "https://#{request.host_with_port}#{@auth_url_facebook}"
      end
      render 'welcome'
    end

    end_time = Time.now
    Logging::log_event(
        user_signed_in ? 'server/home/index' : 'server/home/welcome',
        current_user, end_time - start_time, {})
  end
end
