module Updates
  # Returns the list of interests with updates information (for primaries).
  def self.interests_with_updates(user)
    interests = Interest.where(:user_id => user.id)
    results = []
    interests.each do |interest|
      results << interest_with_updates(interest)
    end
    return results
  end

  # Return a copy of the given interest with update information.
  def self.interest_with_updates(interest)
    result = {
      :id => interest.id,
      :category => interest.category,
      :primary => interest.primary,
    }
    if interest.primary
      new_since, new_count = updates_summary_for(interest)
      result[:last_seen] = interest.last_seen
      result[:new_since] = new_since
      result[:new_count] = new_count
    end
    return result
  end

  # Returns a description of which articles in this category are new. These
  # are (since, count), where since is the time after which an article is new
  # and count is the number of articles published after that time.
  def self.updates_summary_for(interest)
    new_since = Crawl.where('finished < ?', interest.last_seen) \
        .maximum('max_published')
    new_count = Article.joins(:categories) \
        .where('categories.name = ?', interest.category) \
        .where('articles.published > ?', new_since) \
        .count
    return new_since, new_count
  end

  # Returns the articles in this category are new.
  def self.updates_for(interest)
    new_since = Crawl.where('finished < ?', interest.last_seen) \
        .maximum('max_published')
    return Article.joins(:categories) \
        .where('categories.name = ?', interest.category) \
        .where('articles.published > ?', new_since)
  end
end
