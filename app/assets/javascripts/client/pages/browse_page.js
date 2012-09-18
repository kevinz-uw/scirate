var DAYS = 24 * 60 * 60;

function BrowsePage(root, params) {
  this.category = params[0];
  this.timeFrame = (params.length > 1 ? params[1] : 'today');
  this.firstIndex = (params.length > 2 ? parseInt(params[2]) : 0);

  var windowSize = 0, windowOffset = 0;
  if (this.timeFrame == 'today') {
    windowSize = 1 * DAYS;
  } else if (this.timeFrame == 'yesterday') {
    windowSize = 1 * DAYS;
    windowOffset = windowSize;
  } else if (this.timeFrame == 'this-week') {
    windowSize = 7 * DAYS;
  } else if (this.timeFrame == 'last-week') {
    windowSize = 7 * DAYS;
    windowOffset = windowSize;
  } else if (this.timeFrame == 'this-month') {
    windowSize = 30 * DAYS;
  } else if (this.timeFrame == 'last-month') {
    windowSize = 30 * DAYS;
    windowOffset = windowSize;
  } else if (this.timeFrame == 'this-year') {
    windowSize = 365 * DAYS;
  } else if (this.timeFrame == 'last-year') {
    windowSize = 365 * DAYS;
    windowOffset = windowSize;
  } else {
    alert('unknown time frame: "' + this.timeFrame + '"');
    windowSize = 1 * DAYS;
  }

  var cursor = data.findArticles(
      this.category, windowSize, windowOffset, this.firstIndex);

  this.initArticles(root, cursor, true);

  if (this.firstIndex > 0) {
    LogEvent('client/browse', undefined, {'timeFrame': this.timeFrame});
  }
}

$.extend(BrowsePage.prototype, ArticlesPage.prototype);

BrowsePage.TIMEFRAME_STR = {
  'today': 'Today',
  'yesterday': 'Yesterday',
  'this-week': 'This Week',
  'last-week': 'Last Week',
  'this-month': 'This Month',
  'last-month': 'Last Month',
  'this-year': 'This Year',
  'last-year': 'Last Year',
};

BrowsePage.prototype.displayHeader = function(elem, firstIndex, lastIndex) {
  elem.html(browseHeaderTemplate.render({
    category: this.category,
    first_index: firstIndex + 1,
    last_index: lastIndex + 1,
    time_frame_str: BrowsePage.TIMEFRAME_STR[this.timeFrame],
  }));
};

BrowsePage.prototype.displayPager = function(
      elem, firstIndex, lastIndex, atEnd) {
  var urlPrefix = '#browse/' + this.category + '/' + this.timeFrame + '/';
  elem.html(browsePagerTemplate.render({
    category: this.category,
    first_index: firstIndex + 1,
    last_index: lastIndex + 1,
    prev_url: urlPrefix + Math.max(0, firstIndex - this.numVisible),
    next_url: urlPrefix + (lastIndex + 1),
    atEnd: atEnd
  }));
};

BrowsePage.prototype.attachHeader = function() {};

BrowsePage.prototype.attachPager = function() {
  var that = this;
  $('#articles_prev').bind('click', function (evt) {
    // default action will cause an update
    window.scrollTo(0, 0);
  });
  $('#articles_next').bind('click', function (evt) {
    // default action will cause an update
    window.scrollTo(0, 0);
  });
  $('#articles_home').bind('click', function (evt) {
    // default action will cause an update
    window.scrollTo(0, 0);
  });
};

BrowsePage.prototype.detachHeader = function() {};

BrowsePage.prototype.detachPager = function() {
  $('#articles_prev').unbind('click');
  $('#articles_next').unbind('click');
  $('#articles_home').unbind('click');
};
