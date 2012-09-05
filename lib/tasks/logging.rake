require 'scirate/logging'


namespace :logging do
  desc "Remove all events from the logs older than 30 days."
  task :clean => :environment do
    Logging::clean
  end
end
