class Crawl < ActiveRecord::Base
  attr_accessible :finished, :max_published, :max_updated

  validates :finished, :presence => true
  validates :max_published, :presence => true
  validates :max_updated, :presence => true
end
