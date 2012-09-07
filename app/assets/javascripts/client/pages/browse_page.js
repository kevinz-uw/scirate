function BrowsePage(root, params) {
  this.category = params[0];
  this.year = -1;
  this.month = -1;
  this.firstIndex = 0;

  var cursor;
  if (params.length == 1) {
    cursor = data.findArticles(this.category, null, null, this.firstIndex);
  } else if (params.length == 2) {
    this.firstIndex = parseInt(params[1]);
    cursor = data.findArticles(this.category, null, null, this.firstIndex);
  } else if (params.length == 3) {
    this.year = parseInt(params[1]);
    this.firstIndex = parseInt(params[2]);
    cursor = data.findArticles(this.category, this.year, null, this.firstIndex);
  } else if (params.length == 4) {
    this.year = parseInt(params[1]);
    this.month = parseInt(params[2]);
    this.firstIndex = parseInt(params[3]);
    cursor = data.findArticles(
        this.category, this.year, this.month, this.firstIndex);
  } else {
    unexpectedCase("too many params for browse");
  }

  this.initArticles(root, cursor);

  LogEvent('client/browse', undefined,
      {'year': this.year, 'month': this.month});
}

$.extend(BrowsePage.prototype, ArticlesPage.prototype);

BrowsePage.prototype.displayHeader = function(elem, firstIndex, lastIndex) {
  elem.html(browseHeaderTemplate.render({
    category: this.category,
    first_index: firstIndex + 1,
    last_index: lastIndex + 1,
    year: this.year,
    yearStr: (this.year >= 0) ? '' + this.year : "Any year",
    month: this.month,
    monthStr: (this.month > 0) ? MONTH[this.month] : "Any month"
  }));
};

BrowsePage.prototype.displayPager = function(
      elem, firstIndex, lastIndex, atEnd) {
  var urlPrefix = '#browse/' + this.category + '/';
  if (this.year >= 0) {
    urlPrefix += this.year + '/';
    if (this.month > 0) {
      urlPrefix += this.month + '/';
    }
  }

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
