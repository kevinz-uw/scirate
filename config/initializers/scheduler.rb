require 'rufus/scheduler'
require 'scirate/arxiv/crawl'
require 'scirate/recommenders/recommenders'
require 'scirate/logging'


if ENV['RUFUS_SCHEDULER'] != 'no'
  scheduler = Rufus::Scheduler.start_new

  scheduler.cron '45 17 * * *' do
    Arxiv::crawl
  end

  scheduler.cron '45 16 * * *' do
    Recommenders::update_user_models
  end

  scheduler.cron '30 16 * * *' do
    Recommenders::update_global_model
  end

  scheduler.cron '00 00 * * *' do
    Logging::clean
  end
end
