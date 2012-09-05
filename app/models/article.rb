class Article < ActiveRecord::Base
  attr_accessible :arxiv_id, :title, :abstract, :comments,
      :doi, :journal_ref, :report_no, :msc_class, :acm_class,
      :authors_attributes, :submitter,
      :categories_attributes, :primary_category,
      :versions_attributes, :published, :last_updated

  validates :arxiv_id, :presence => true, :length => {:in => 7..50}
  validates :title, :presence => true
  validates :primary_category, :presence => true, :length => {:maximum => 50}
  validates :published, :presence => true
  validates :last_updated, :presence => true

  has_many :authors, :autosave => true, :validate => true,
      :dependent => :destroy, :inverse_of => :article
  has_many :categories, :autosave => true, :validate => true,
      :dependent => :destroy, :inverse_of => :article
  has_many :versions, :autosave => true, :validate => true,
      :dependent => :destroy, :inverse_of => :article

  accepts_nested_attributes_for :authors, :categories, :versions

  def all_author_names
    return authors.map {|c| c.name}.join(", ")
  end

  def all_author_names_and_institutions
    return authors.map {|c| c.name_and_institution}.join(", ")
  end

  def all_category_names
    return categories.map {|c| c.name}.join(", ")
  end

  # Determines whether this article is identical to that described.
  def is_identical?(record)
    raise 'wrong ID' if record[:arxiv_id] != arxiv_id

    if title != record[:title] or abstract != record[:abstract] or
       comments != record[:comments] or doi != record[:doi] or
       journal_ref != record[:journal_ref] or
       report_no != record[:report_no] or msc_class != record[:msc_class] or
       acm_class != record[:acm_class] or submitter != record[:submitter] or
       primary_category != record[:primary_category] or
       published != record[:published] or
       last_updated != record[:last_updated]
      return false
    end

    return false if authors.length != record[:authors_attributes].length
    cur_authors = {}
    authors.each do |v|
      cur_authors[v.name] = v
    end
    record[:authors_attributes].each do |r|
      return false if not cur_authors.include? r[:name]
      return false if not cur_authors[r[:name]].is_identical? r
    end

    return false if categories.length != record[:categories_attributes].length
    cur_names = categories.map {|a| a.name}.sort
    new_names = record[:categories_attributes].map {|a| a[:name]}.sort
    return false if cur_names != new_names

    return false if versions.length != record[:versions_attributes].length
    cur_versions = {}
    versions.each do |v|
      cur_versions[v.name] = v
    end
    record[:versions_attributes].each do |r|
      return false if not cur_versions.include? r[:name]
      return false if not cur_versions[r[:name]].is_identical? r
    end

    return true
  end
end

class Author < ActiveRecord::Base
  attr_accessible :name, :institution

  validates :name, :presence => true

  belongs_to :article, :inverse_of => :authors

  # Formats the name together with the institution.
  def name_and_institution
    if institution
      return "#{name} (#{institution})"
    else
      return name
    end
  end

  # Determines whether this author is identical to that described.
  def is_identical?(record)
    return (name == record[:name] and
            institution == record[:institution])
  end
end

class Category < ActiveRecord::Base
  attr_accessible :name

  validates :name, :presence => true

  belongs_to :article, :inverse_of => :categories
end

class Version < ActiveRecord::Base
  attr_accessible :name, :size, :timestamp

  validates :name, :presence => true
  validates :size, :length => {:maximum => 50}
  validates :timestamp, :presence => true

  belongs_to :article, :inverse_of => :versions

  # Determines whether this version is identical to that described.
  def is_identical?(record)
    return (name == record[:name] and size == record[:size] and
        timestamp == record[:timestamp])
  end
end
