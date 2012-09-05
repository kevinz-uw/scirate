ACTIVITY_CLIENT_LOAD = 'client/load'
ACTIVITY_CLIENT_SETTINGS = 'client/settings'
ACTIVITY_CLIENT_NEW = 'client/new'
ACTIVITY_CLIENT_BROWSE = 'client/browse'

ACTIVITY_SERVER_LOGIN = 'server/login'
ACTIVITY_SERVER_ARTICLES_INDEX = 'server/articles/index'
ACTIVITY_SERVER_INTERESTS_INDEX = 'server/interests/index'
ACTIVITY_SERVER_INTERESTS_CREATE = 'server/interests/create'
ACTIVITY_SERVER_INTERESTS_UPDATE = 'server/interests/update'
ACTIVITY_SERVER_INTERESTS_DESTROY = 'server/interests/destroy'
ACTIVITY_SERVER_RATINGS_CREATE = 'server/ratings/create'
ACTIVITY_SERVER_USERS_UPDATE = 'server/users/update'

ACTIVITY_TASK_CRAWL = 'task/arxiv/crawl'
ACTIVITY_TASK_RECOMMENDER_USERS = 'task/recommender/update_users'
ACTIVITY_TASK_RECOMMENDER_GLOBAL = 'task/recommender/update_global'

class Event < ActiveRecord::Base
  attr_accessible :activity  # string name above
  attr_accessible :at        # Time of start
  attr_accessible :duration  # length of time in seconds (a float)
  attr_accessible :user_id

  validates :activity, :presence => true
  validates :at, :presence => true

  has_many :params, :autosave => true, :validate => true,
      :dependent => :destroy, :inverse_of => :event, :class_name => 'EventParam'

  accepts_nested_attributes_for :params
end

class EventParam < ActiveRecord::Base
  attr_accessible :key, :str_value, :int_value, :float_value

  validates :key, :presence => true

  belongs_to :event, :inverse_of => :params
end
