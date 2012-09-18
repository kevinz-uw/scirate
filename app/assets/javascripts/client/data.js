// Stores, fetches, and caches data from the server.
function Data() {
  this.user = {
    name: userName,
    email: userEmail,
    allowEmail: userAllowEmail,
    interests: userInterests
  };

  for (var i = 0; i < this.user.interests.length; i++) {
    this._prepareInterest(this.user.interests[i]);
  }

  this.queries = {};
}

// Adds new fields to the given objects with parsed versions of the date fields.
Data.parseDates = function (obj, fields) {
  if ($.isArray(obj)) {
    for (var i = 0; i < obj.length; i++) {
      Data.parseDates(obj[i], fields);
    }
  } else {
    assert($.isPlainObject(obj));
    for (var i = 0; i < fields.length; i++) {
      var field = fields[i];
      if (field in obj) {
        obj[field + '_date'] = new Date(Date.parse(obj[field]));
      }
    }
  }
};

// Replaces the accents in author names in the given articles.
Data.replaceAccents = function(articles) {
  for (var i = 0; i < articles.length; i++) {
    var article = articles[i];
    if (article.submitter) {
      article.submitter = replaceAccents(article.submitter);
    }
    for (var j = 0; j < article.authors.length; j++) {
      var author = article.authors[j];
      author.name = replaceAccents(author.name);
    }
  }
};

// Determines whether the user has any new articles to read.
Data.prototype.hasNewArticles = function() {
  for (var i = 0; i < this.user.interests.length; i++) {
    var interest = this.user.interests[i];
    if (interest.primary && interest.new_count > 0) {
      return true;
    }
  }
  return false;
};

// Updates the user name.
Data.prototype.setName = function(name) {
  this.user.name = name;

  var postData = getAuthData();
  postData['name'] = name;
  $.ajax({
      url: '/user?format=json',
      type: 'PUT',
      data: postData,
      dataType: 'json'
    }).success($.noop)
    .error(unexpectedServerError);
};

// Updates the user's allow-email bit.
Data.prototype.setAllowEmail = function(allowEmail) {
  this.user.allowEmail = allowEmail;

  var postData = getAuthData();
  postData['allow_email'] = allowEmail;
  $.ajax({
      url: '/user?format=json',
      type: 'PUT',
      data: postData,
      dataType: 'json'
    }).success($.noop)
    .error(unexpectedServerError);
};

// Returns the interest for the given category (if any).
Data.prototype.findInterest = function(category) {
  for (var i = 0; i < this.user.interests.length; i++) {
    if (this.user.interests[i].category == category) {
      return this.user.interests[i];
    }
  }
  return null;
};

// Adds the given interest (or updates it if it exists already).
Data.prototype.addInterest = function(category, primary, completed) {
  var interest = this.findInterest(category);
  if (interest) {
    if (interest.primary != primary) {
      // We can update the local data right away.
      interest.primary = primary;
      completed();

      // Notify the server after the fact.
      var postData = getAuthData();
      postData['primary'] = primary;
      $.ajax({
          url: '/interests/' + interest.id + '?format=json',
          type: 'POST',
          data: postData,
          dataType: 'json'
        }).success($.noop)
        .error(unexpectedServerError);
    }
  } else {
    // We first need the server data (for last_seen and id0.
    var that = this;
    var postData = getAuthData();
    postData['category'] = category;
    postData['primary'] = primary;
    $.ajax({
        url: '/interests?format=json',
        type: 'POST',
        data: postData,
        dataType: 'json'
      }).success(function (data, statusText, xhr) {
        // Now perform a local update.
        that.user.interests.push(data);
        that._prepareInterest(data);
        completed.call();
      }).error(unexpectedServerError);
  }
};

// Removes the given interest.
Data.prototype.removeInterest = function(category, completed) {
  var interest = this.findInterest(category);
  assert(interest, 'interest != null');
  var index = this.user.interests.indexOf(interest);
  assert(index >= 0, 'index >= 0');

  // We can update the local data right away.
  this.user.interests.splice(index, 1);
  completed.call();

  // Notify the server after the fact.
  $.ajax({
      url: '/interests/' + interest.id + '?format=json',
      type: 'DELETE',
      data: getAuthData(),
      dataType: 'json'
    }).success($.noop)
    .error(unexpectedServerError);
};

// Prepares server-side description to be used on the client.
Data.prototype._prepareInterest = function(interest) {
  Data.parseDates(interest, ['last_seen']);

  // Keep track of where the user is in each list of new articles.
  if (interest.primary) {
    interest.new_index = 0;
  }

  // Pre-fetch articles for primary interests.
  if (interest.primary && !interest.articles) {
    $.ajax({
        url: '/articles?format=json' +
             '&category=' + encodeURIComponent(interest.category) +
             '&since=' + encodeURIComponent(interest.new_since) +
             '&updates',
        dataType: 'json'
      }).success(function (data, statusText, xhr) {
        try {
          Data.replaceAccents(data);

          interest.articles = data;
          if (interest.articlesListener) {
            interest.articlesListener(interest, data);
            interest.articlesListener = null;
          }
        } catch (ex) {
          unexpectedException(ex);
        }
      }).error(unexpectedServerError);
  }
};

// Maximum number of articles to display at once. This is also used to
// determine the amount to prefetch.
Data.MAX_PAGE_SIZE = 25;

// Number of pages to fetch at once.
Data.PAGES_PER_FETCH = 4;

// Returns the articles matching the given query. The window is the period of
// time in which to return articles. These are both in seconds since the last
// crawl (i.e., the maximum published time in the database).
//
// NOTE: We could prefetch these as well, but it's not clear that users will
// very often page beyond the first set returned.
Data.prototype.findArticles = function(
    category, windowSize, windowOffset, firstIndex) {
  var key = Data._makeQueryKey(category, windowSize, windowOffset);
  var cursor = this.queries[key];
  if (!cursor) {
    cursor = this.queries[key] = {articles: []};
  }

  if (cursor.done ||
      (firstIndex + Data.MAX_PAGE_SIZE <= cursor.articles.length)) {
    return cursor;
  }
  alert('not enough: length=' + cursor.articles.length + ' at=' + firstIndex);

  var limit = Math.max(
      firstIndex + Data.MAX_PAGE_SIZE - cursor.articles.length,
      Data.PAGES_PER_FETCH * Data.MAX_PAGE_SIZE);

  var sinceDate = new Date(maxPublished.getTime() -
      1000 * (windowSize + windowOffset));
  var untilDate = new Date(maxPublished.getTime() - 1000 * windowOffset);
  var since = formatDate(sinceDate);
  var until = formatDate(untilDate);

  var articles = cursor.articles;
  delete cursor.articles;  // indicates still loading

  $.ajax({
      url: '/articles?format=json' +
           '&category=' + encodeURIComponent(category) + 
           (since ? '&since=' + encodeURIComponent(since) : '') +
           (until ? '&until=' + encodeURIComponent(until) : '') +
           '&offset=' + firstIndex + '&limit=' + limit,
      dataType: 'json'
    }).success(function (data, statusText, xhr) {
      try {
        Data.replaceAccents(data);

        if (!cursor.articles ||
            (cursor.articles.length < firstIndex + data.length)) {
          cursor.articles = articles.slice(0, firstIndex).concat(data);
          if (data.length < limit) {
            cursor.done = true;  // no reason to make more queries
          }
        }

        if (cursor.articlesListener) {
          cursor.articlesListener(cursor, cursor.articles);
          cursor.articlesListener = null;
        }
      } catch (ex) {
        unexpectedException(ex);
      }
    }).error(unexpectedServerError);

  return cursor;
};

// Changes the rating on the given article. This will also update the scite
// count to take into account this scite.
Data.prototype.rateArticle = function(article, rating) {
  if (rating == 0) {
    if (article.scited) {
      article.scited = false;
      article.scites -= 1;
    }
  } else if (rating == 4) {
    if (!article.scited) {
      article.scited = true;
      article.scites = (article.scites ? article.scites : 0) + 1;
    }
  } else {
    if (article.scited) {
      return;  // this would be ignored, so don't send it
    }
  }

  var postData = getAuthData();
  postData['article_id'] = article.id;
  postData['rating_action'] = rating;
  $.ajax({
      url: '/ratings?format=json',
      type: 'POST',
      data: postData,
      dataType: 'json'
    }).success($.noop)
    .error(unexpectedServerError);
};

// Creates a unique key to describe the given query.
Data._makeQueryKey = function(category, windowSize, windowOffset) {
  return category + '/' + windowSize + '/' + windowOffset;
};

// Maintain a singleton instance in the global variable 'data'.
var data = new Data();
