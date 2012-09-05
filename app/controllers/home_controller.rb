require 'scirate/logging'
require 'scirate/updates'

class HomeController < ApplicationController
  def index
    start_time = Time.now

    if user_signed_in
      @interests = Updates::interests_with_updates(current_user)
      render # index
    else
      render 'welcome'
    end

    end_time = Time.now
    Logging::log_event(
        user_signed_in ? 'server/home/index' : 'server/home/welcome',
        current_user, end_time - start_time, {})
  end
end
