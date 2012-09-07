require 'date'
require 'net/http'
require 'uri'
require 'xml/libxml'

require 'scirate/arxiv/format'


# URLs and paths for working with OAI.
OAI_NS = 'oai:http://www.openarchives.org/OAI/2.0/'
OAI_RECORD_PATH = '/oai:OAI-PMH/*/oai:record'
OAI_RES_TOKEN_PATH = '/oai:OAI-PMH/*/oai:resumptionToken'
OAI_ERROR_PATH = '/oai:OAI-PMH/oai:error'
ARXIV_NS = 'ar:http://arxiv.org/OAI/arXivRaw/'

# Minimum the amount of time between requests (required by arxiv.org).
ARXIV_RESUME_SEC = 20

# Fields whose value is a simple string.
SINGLETON_STR_FIELDS = %w{title abstract submitter comments doi journal-ref
    msc-class acm-class report-no}

# Fields whose value can be arbitrarily long.
LONG_FIELDS = %w{title abstract comments}

# Fields returned by arxiv that we currently ignore.
IGNORED_FIELDS = %w{license proxy}

# Keys to indicate what sort of record was found.
RECORD_CREATE = 1
RECORD_DELETE = 2
RECORD_UPDATE = 3
RECORD_NO_CHANGE = 4

# Output logging information during this task.
if Rails.logger
  LOG = Rails.logger
else
  LOG = Logger.new(STDOUT)
  LOG.level = Logger::INFO
  LOG.formatter = proc { |sev, ts, progname, msg|
    "[#{ts.strftime('%Y-%b-%d %H:%m:%S')}] #{sev.upcase}  #{msg}\n"
  }
end

# A time earlier than anything in the arXiv.
ARXIV_START = DateTime.parse('1990-01-01T00:00:00')


module Arxiv

  # Crawls the arxiv for new articles.
  def self.crawl
    LOG.info 'crawling the arxiv for new articles'

    min_published = Article.maximum(:published) || ARXIV_START
    min_updated = Article.maximum(:last_updated) || ARXIV_START

    max_published = min_published
    max_updated = min_updated

    find_arxiv_records do |node|
      record = parse_arxiv_record(node)
      if not record
        next RECORD_DELETE
      end

      if record[:published] > min_published
        max_published = [record[:published], max_published].max
      end
      if record[:last_updated] > min_updated
        max_updated = [record[:last_updated], max_updated].max
      end

      article = Article.includes(:authors, :categories, :versions) \
                       .find_by_arxiv_id(record[:arxiv_id])
      if not article
        article = Article.new(parse_arxiv_record(node))
        if not article.save
          print_article_errors(article)
      end
        next RECORD_CREATE
      end

      if not article.is_identical? record
        article.delete
        article = Article.new(parse_arxiv_record(node))
        if not article.save
          print_article_errors(article)
        end
        next RECORD_UPDATE
      end

      next RECORD_NO_CHANGE
    end

    if (max_published > min_published) or (max_updated > min_updated)
      crawl = Crawl.new(:finished => DateTime.now,
          :max_published => max_published, :max_updated => max_updated)
      if not crawl.save
        LOG.error 'failed to save crawl information'
        crawl.errors.each do |err|
          LOG.error err
        end
      end
    end

    LOG.info 'database now contains %d articles' % Article.count
    LOG.info 'crawling completed'
  end

  # Retrieves the XML description of each record for the appropriate query and
  # yields them to the provided block.
  def self.find_arxiv_records
    res_token = nil
    while true
      # Construct the URL for this request.
      if res_token
        path_str = '/oai2?verb=ListRecords'
        path_str += "&resumptionToken=#{URI.escape(res_token)}"
      else
        path_str = make_arxiv_query
      end

      # Retrieve the next batch of records.
      response = nil
      Net::HTTP.start('export.arxiv.org', 80) do |http|
        http.read_timeout = 5 * 60
        response = http.request_get(path_str)
      end
      if response.code != '200'
        fatal "request failed: #{response.code} #{response.message}"
      end

      start_time = Time.now.to_i

      # Parse the records into a document.
      parser = XML::Parser.string(response.body)
      doc = parser.parse
 
      # Look for an error response.
      error_nodes = doc.find(OAI_ERROR_PATH, OAI_NS)
      if error_nodes.length > 0
        err = error_nodes[0]
        fatal "request error: #{err.attributes['code']}: #{err.content}"
      end

      # Look for the returned records.
      record_nodes = doc.find(OAI_RECORD_PATH, OAI_NS)

      # Look for a resumption token.
      res_token_nodes = doc.find(OAI_RES_TOKEN_PATH, OAI_NS)
      if res_token_nodes.length > 0
        res_token_node = res_token_nodes[0]
        cursor = Integer(res_token_node.attributes['cursor'])
        list_size = Integer(res_token_node.attributes['completeListSize'])
        LOG.info 'retrieved records %d..%d of %d' % [
            cursor + 1, cursor + record_nodes.length, list_size]
      else
        LOG.info 'retrieved all %d records' % record_nodes.length
      end

      # Process each of the record nodes.
      created = deleted = updated = no_change = 0
      record_nodes.each do |record_node|
        type = yield record_node
        if type == RECORD_CREATE
          created += 1
        elsif type == RECORD_DELETE
          deleted += 1
        elsif type == RECORD_UPDATE
          updated += 1
        elsif type == RECORD_NO_CHANGE
          no_change += 1
        end
      end
      LOG.info '  articles: %d created, %d deleted, %d updated, %d no change' %\
          [created, deleted, updated, no_change]

      end_time = Time.now.to_i

      # Start the next request or quit if no more.
      if res_token_nodes.length > 0 and res_token_node.content.length > 0
        res_token = res_token_node.content
        sleep [3, ARXIV_RESUME_SEC - (end_time - start_time)].max
      else
        break
      end
    end
  end

  # Returns the URL path for the appropriate query to perform
  def self.make_arxiv_query
    if ENV['arxiv_id']
      # Construct a URL to retrieve a single record for the given ID.
      path_str = '/oai2?verb=GetRecord'
      path_str += "&identifier=oai:arXiv.org:#{ENV['arxiv_id']}"
      path_str += '&metadataPrefix=arXivRaw'
      return path_str
    end

    # Determine the subject set of documents to search.
    if ENV['arxiv_subject']
      subject = ENV['arxiv_subject']
    else
      subject = nil
    end

    # Determine the minimum update time for the documents to retrieve.
    if ENV['arxiv_start_date']
      start_date = ENV['arxiv_start_date']
    elsif Article.count == 0
      start_date = nil

      LOG.info 'database initially empty'
    else
      last = Article.maximum('last_updated')
      start_date = Date.new(last.year, last.month, last.day) \
                       .strftime('%Y-%m-%d')

      LOG.info 'database initially contains %d articles' % Article.count
      LOG.info 'last article update at %s' % start_date
    end

    # Determine the maximum update time for the documents to retrieve.
    end_date = ENV['arxiv_end_date']

    # Construct a URL to retrieve the next batch of records. Note that we do not
    # include any other parameters if a resumption token is used.
    path_str = '/oai2?verb=ListRecords'
    if subject
      path_str += "&set=#{subject}"
    end
    if start_date
      path_str += "&from=#{start_date}"
    end
    if end_date
      path_str += "&until=#{end_date}"
    end
    path_str += '&metadataPrefix=arXivRaw'
    return path_str
  end

  # Parses an arxiv article XML record into JSON.
  def self.parse_arxiv_record(record_node)
    fatal 'bad record root' if record_node.name != 'record'

    head_nodes = record_node.find('.//oai:header', OAI_NS)
    fatal('wrong metadata format', record_node) if head_nodes.length != 1
    head_node = head_nodes[0]
    return nil if 'deleted' == head_node.attributes['status']

    data_nodes = record_node.find('.//ar:arXivRaw', ARXIV_NS)
    fatal('wrong metadata format', record_node) if data_nodes.length != 1
    data_node = data_nodes[0]

    record = {:versions_attributes => []}
    data_node.each_element do |elem|
      if SINGLETON_STR_FIELDS.include? elem.name
        fatal "repeated singleton field #{elem.name}" \
            if record.include? elem.name
        key = elem.name.gsub('-', '_')
        value = elem.content.strip
        if (! LONG_FIELDS.include? key) and (value.length > 255)
          $stderr.puts "Entry too long: #{key}='#{value}'"
          value = value[0..250] + '...'
        end
        record[key.to_sym] = value
      elsif 'id' == elem.name
        fatal "repeated singleton field #{elem.name}" \
            if record.include? 'arxiv_id'
        record[:arxiv_id] = elem.content.strip
      elsif 'authors' == elem.name
        fatal "repeated singleton field #{elem.name}" \
            if record.include? :authors_attributes
        record[:authors_attributes] = Arxiv::parse_authors(elem.content.strip)
      elsif 'categories' == elem.name
        fatal "repeated singleton field #{elem.name}" \
            if record.include? :categories_attributes
        names = elem.content.split(/\s+/)
        fatal 'article has no categories' if names.size == 0
        record[:primary_category] = names[0]
        record[:categories_attributes] = []
        names.each do |name|
          record[:categories_attributes] << {:name => name}
        end
      elsif 'version' == elem.name
        version = {:name => elem.attributes['version']}
        elem.each_element do |child|
          if 'date' == child.name
            fatal "repeated singleton field date" if version.include? 'date'
            version[:timestamp] = DateTime.strptime(
                child.content.strip, '%a, %d %b %Y %H:%M:%S %Z')
          elsif 'size' == child.name
            fatal "repeated singleton field size" if version.include? 'size'
            version[:size] = child.content
          elsif 'source_type' == child.name
            # ignore this (not sure what it is)
          else
            fatal "unknown field #{child.name} in version"
          end
        end
        record[:versions_attributes] << version
      elsif IGNORED_FIELDS.include? elem.name
        # ignore these
      else
        fatal "unknown field #{elem.name} in record", record_node
      end
    end

    # Compute two synthetic fields from the full version information.
    record[:published] = \
        record[:versions_attributes].map{|v| v[:timestamp]}.min
    record[:last_updated] = \
        record[:versions_attributes].map{|v| v[:timestamp]}.max

    # Make sure that the article has at least one author, category, and version.
    # (Note that non-nested attributes will be validated by the model.)
    fatal 'article has no authors' if record[:authors_attributes].length == 0
    fatal 'article has no versions' if record[:versions_attributes].length == 0
    fatal 'article has no categories' \
        if record[:categories_attributes].length == 0

    return record
  end

  # Records a fatal error and stops execution.
  def self.fatal(msg, record=nil)
    LOG.fatal "fatal error: #{msg}"
    LOG.fatal "debug information: #{record}" if record
    raise "Fatal Error: #{msg}"
  end

  # Prints out any errors that occurred during saving.
  def self.print_article_errors(article)
    LOG.error 'failed to save article %s' % article.arxiv_id
    article.errors.each do |err|
      LOG.error err
    end
    article.authors.each do |author|
      author.errors.each do |err|
        LOG.error err
      end
    end
    article.categories.each do |category|
      category.errors.each do |err|
        LOG.error err
      end
    end
    article.versions.each do |version|
      version.errors.each do |err|
        LOG.error err
      end
    end
  end
end
