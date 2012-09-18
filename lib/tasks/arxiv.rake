require 'scirate/arxiv/crawl'
require 'scirate/arxiv/format'
require 'scirate/logging'


namespace :arxiv do
  desc "Crawl the arxiv for new articles."
  task :crawl => :environment do
    start_time = Time.now

    Arxiv::crawl

    end_time = Time.now
    Logging::log_event('task/arxiv/crawl', nil, end_time - start_time, {})
  end

  desc "Set the default value in scites column."
  task :set_scites_defaults => :environment do
    Article.update_all('scites = 0')
  end
end
