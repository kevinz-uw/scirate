require 'scirate/arxiv/crawl'
require 'scirate/arxiv/format'
require 'scirate/logging'


namespace :arxiv do
  desc "Crawl the arxiv for new articles."
  task :crawl => :environment do
    start_time = Time.now

    Arxiv::crawl

    end_time = Time.now
    Logging::LogEvent('task/arxiv/crawl', nil, end_time - start_time, {})
  end
end
