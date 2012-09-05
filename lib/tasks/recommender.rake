require 'scirate/recommenders/recommenders'


namespace :recommender do
  desc "Update the recommendations for any users with ratings."
  task :update_users => :environment do
    start_time = Time.now

    Recommenders::update_user_models

    end_time = Time.now
    Logging::LogEvent('task/recommender/update_users', nil,
        end_time - start_time, {})
  end

  desc "Updates the global preference for each article."
  task :update_global => :environment do
    start_time = Time.now

    Recommenders::update_global_model

    end_time = Time.now
    Logging::LogEvent('task/recommender/update_global', nil,
        end_time - start_time, {})
  end
end
