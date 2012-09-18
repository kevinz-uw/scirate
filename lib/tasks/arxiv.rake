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

  desc "Clean up the scites column."
  task :add_missing_scites_defaults => :environment do
    Article.where('scites IS NULL').each do |article|
      article.scites = 0
      article.save!
    end
  end
end
