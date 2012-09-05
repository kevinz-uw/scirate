class Keyword
  LOCATION_AUTHORS = 1
  LOCATION_TITLE = 2
  LOCATION_ABSTRACT = 3

  attr_accessor :article_id, :word, :location

  def initialize(article_id, word, location)
    @article_id = article_id
    @word = word
    @location = location
  end

  # Returns the keywords for the given article, each as a pair (word, location)
  def self.all_from(article)
    keywords = {}
    tokenize(article.abstract).each do |w|
      keywords[w] = Keyword::LOCATION_ABSTRACT
    end
    tokenize(article.title).each do |w|
      keywords[w] = Keyword::LOCATION_TITLE
    end
    article.authors.each do |author|
      tokenize(author.name).each do |w|
        keywords[w] = Keyword::LOCATION_AUTHORS
      end
      if author.institution
        tokenize(author.institution).each do |w|
          keywords[w] = Keyword::LOCATION_AUTHORS
        end
      end
    end

    result = []
    keywords.each_pair do |word, loc|
      result << Keyword.new(article.id, word, loc)
    end
    return result
  end

  # Returns the searchable tokens in the given string.
  private
  def self.tokenize(str)
    return str.scan(/[a-zA-Z]+/) \
              .map {|w| w.downcase} \
              .reject {|w| ignored_keyword? w}
  end

  # Returns whether the given keyword should not be indexed (ignored).
  private
  def self.ignored_keyword?(w)
    return (w.length <= 1 or IGNORED_WORDS[w])
  end

  # List of words to be ignored during tokenization.
  IGNORED_WORDS_LIST = [
    # coordinating conjunctions
    'and', 'nor', 'but', 'or', 'yet', 'so',
    # subordinating conjunections
    'after', 'although', 'as', 'because', 'before', 'if', 'though', 'till',
    'unless', 'until', 'when', 'whenever', 'where', 'wherever', 'while',
    # correlative conjunctions
    'both', 'either', 'neither', 'only', 'also', 'whether',
    # articles
    'a', 'an', 'the',
    # determiners
    'this', 'that', 'these', 'my', 'your', 'his', 'her', 'its', 'our', 'their',
    'whose', 'which', 'what',
    # preposition
    'at', 'between', 'by', 'for', 'from', 'in', 'into', 'like', 'of', 'on',
    'onto', 'than', 'through', 'to', 'with',
    # pronoun
    'I', 'me', 'you', 'he', 'him', 'she', 'her', 'it', 'we', 'us', 'you',
    'they', 'them',
    # adverbs
    'not', 'just', 'very', 'how', 'here', 'there', 'since', 'then',
    # adjective
    'non', 'such',
    # verbs
    'be', 'am', 'is', 'are', 'being', 'was', 'were', 'been', 
    'have', 'has', 'had', 'having', 
    'can', 'could', 
    'do', 'did', 'does', 'doing', 
    'may', 'might', 'must', 'shall', 'should', 'will', 'would', 
  ]

  # Hash version of the above list.
  IGNORED_WORDS = {}
  IGNORED_WORDS_LIST.each do |w|
    IGNORED_WORDS[w] = true
  end
end
