require 'scirate/logging'

class UsersController < ApplicationController
  before_filter :check_authorized

  def update
    start_time = Time.now

    if params.include? :name
      @current_user.name = params[:name]
    end
    if params.include? :allow_email
      @current_user.allow_email = (params[:allow_email] == 'true')
    end
    @current_user.save!

    respond_to do |format|
      format.json { render :json => @current_user.errors }
    end

    end_time = Time.now
    Logging::log_event('server/users/update', current_user,
        end_time - start_time, {})
  end
end
