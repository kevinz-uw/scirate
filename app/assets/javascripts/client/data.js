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
      Data._parseDates(obj[i], fields);
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

  var data = getAuthData();
  data['name'] = name;
  $.ajax({
      url: '/user?format=json',
      type: 'PUT',
      data: data,
      dataType: 'json'
    }).success($.noop)
    .error(unexpectedServerError);
};

// Updates the user's allow-email bit.
Data.prototype.setAllowEmail = function(allowEmail) {
  this.user.allowEmail = allowEmail;

  var data = getAuthData();
  data['allow_email'] = allowEmail;
  $.ajax({
      url: '/user?format=json',
      type: 'PUT',
      data: data,
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
      var data = getAuthData();
      data['primary'] = primary;
      $.ajax({
          url: '/interests/' + interest.id + '?format=json',
          type: 'POST',
          data: data,
          dataType: 'json'
        }).success($.noop)
        .error(unexpectedServerError);
    }
  } else {
    // We first need the server data (for last_seen and id0.
    var that = this;
    var data = getAuthData();
    data['category'] = category;
    data['primary'] = primary;
    $.ajax({
        url: '/interests?format=json',
        type: 'POST',
        data: data,
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
Data.MAX_PAGE_SIZE = 50;

// Number of pages to fetch at once.
Data.PAGES_PER_FETCH = 2;

// Returns the articles matching the given query. Year and month are optional.
// NOTE: We could prefetch these as well, but it's not clear that users will
// very often page beyond the first set returned.
Data.prototype.findArticles = function(category, year, month, firstIndex) {
  var key = Data._makeQueryKey(category, year, month);
  var cursor = this.queries[key];
  if (!cursor) {
    cursor = this.queries[key] = {articles: []};
  }

  if (firstIndex + Data.MAX_PAGE_SIZE <= cursor.articles.length) {
    return cursor;
  }

  var limit = Math.max(
      firstIndex + Data.MAX_PAGE_SIZE - cursor.articles.length,
      Data.PAGES_PER_FETCH * Data.MAX_PAGE_SIZE);

  var since, until;
  if (year != null) {
    if (month != null) {
      var mon = (month < 10) ? '0' + month : '' + month;
      var day = (DAYS[month] < 10) ? '0' + DAYS[month] : '' + DAYS[month];
      since = year + '-' + mon + '-01 00:00:00 UTC';
      until = year + '-' + mon + '-' + day + ' 23:59:59 UTC';
    } else {
      since = year + '-01-01 00:00:00 UTC';
      until = year + '-12-31 23:59:59 UTC';
    }
  }

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
        if (!cursor.articles ||
            (cursor.articles.length < articles.length + data.length)) {
          cursor.articles = articles.concat(data);
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

// Creates a unique key to describe the given query.
Data._makeQueryKey = function(category, year, month) {
  if (year) {
    if (month) {
      return category + '/' + year + '/' + month;
    } else {
      return category + '/' + year;
    }
  } else {
    return category;
  }
};

// Maintain a singleton instance in the global variable 'data'.
var data = new Data();
