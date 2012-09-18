class User < ActiveRecord::Base
  attr_accessible :email, :name
  attr_accessible :allow_email  # whether the user allows us to email them

  validates :email, :presence => true, :uniqueness => true
  validates :name, :presence => true

  has_many :interests, :autosave => true, :validate => true,
      :dependent => :destroy, :inverse_of => :user
  has_many :ratings, :autosave => true, :validate => true,
      :dependent => :destroy, :inverse_of => :user
end

# Represents a category that the user is interested in.
class Interest < ActiveRecord::Base
  attr_accessible :category, :primary, :last_seen

  validates :category, :presence => true
  validates_inclusion_of :primary, :in => [true, false]  # booleans are special
  validates :last_seen, :presence => true

  belongs_to :user, :inverse_of => :interests

  has_one :model, :autosave => true, :validate => true,
      :dependent => :destroy, :inverse_of => :interest
end

# A statistical model for explaining (and predicting) this user's ratings for
# this interest.
class Model < ActiveRecord::Base
  attr_accessible :method

  validates :method, :presence => true

  belongs_to :interest, :inverse_of => :model

  has_many :params, :autosave => true, :validate => true,
      :dependent => :destroy, :inverse_of => :model, :class_name => 'ModelParam'

  accepts_nested_attributes_for :params
end

# Part of a list of parameters describing a model.
class ModelParam < ActiveRecord::Base
  attr_accessible :key, :value

  validates :key, :presence => true
  validates :value, :presence => true

  belongs_to :model, :inverse_of => :params
end

# We keep track of the maximum of the following types of actions, which
# indicate strengths of rating.
RATING_ACTION_DISLIKE = -4
RATING_ACTION_SEEN = 0
RATING_ACTION_EXPAND = 1
RATING_ACTION_ARXIV = 2
RATING_ACTION_PDF = 3
RATING_ACTION_SCITE = 4
RATING_ACTION_MAXIMUM = 4

# User's rating of an individual article.
class Rating < ActiveRecord::Base
  attr_accessible :article_id, :action

  validates :article_id, :presence => true
  validates :action, :presence => true

  belongs_to :user, :inverse_of => :ratings
end
