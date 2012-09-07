function ArticlesPage() { /* unused */ }

$.extend(ArticlesPage.prototype, Page.prototype);

// Records the list of articles for use displaying.
ArticlesPage.prototype.initArticles = function(root, cursor) {
  this.root = root;
  this.cursor = cursor;
};

ArticlesPage.prototype.display = function() {
  this.root.html(articlesHtmlTemplate.render({
    headerID: 'header', pagerID: 'pager', resultsID: 'results'
  }));

  if (this.cursor.articles) {
    this._computeLastIndex();

    this.displayHeader($('#header'), this.firstIndex, this.lastIndex);
    this.displayPager($('#pager'), this.firstIndex, this.lastIndex, this.atEnd);
    $('#results').html(articlesResultsTemplate.render({
      articles: this.cursor.articles.slice(this.firstIndex, this.lastIndex + 1)
    }));
  } else {
    // Finish this display once the articles are loaded.
    var that = this;
    this.cursor.articlesListener = function () {
      that.redisplay();
    };
  }
};

// Fills in the last index to be displayed.
ArticlesPage.prototype._computeLastIndex = function() {
  // Limit the amount of data shown on one page to the prefetch size.
  var numRemaining = Math.min(
      this.cursor.articles.length - this.firstIndex, Data.MAX_PAGE_SIZE);
  this.numVisible = this._maxVisibleResults();
  var numShown = Math.min(this.numVisible, numRemaining);
  this.lastIndex = this.firstIndex + numShown - 1;
  this.atEnd = (numRemaining < Data.MAX_PAGE_SIZE) &&
      (this.lastIndex + 1 == this.cursor.articles.length);
};

// Returns the number of results that can fit on one page.
ArticlesPage.prototype._maxVisibleResults = function() {
  if (this.cursor.articles.length <= 1) {
    return 1;
  }

  // Create an off-screen buffer in which to draw.
  var div = $('<div/>');
  div.css('position', 'absolute');
  div.css('top', '0');
  div.css('left', '-10000px');
  div.html(articlesHtmlTemplate.render({
    category: this.category,
    headerID: 'header2', pagerID: 'pager2', resultsID: 'results2',
  }));
  this.displayHeader($('#header2'), this.firstIndex, this.firstIndex);
  this.displayPager($('#pager2'), this.firstIndex, this.firstIndex, false);
  $('BODY').append(div);

  // Measure the height of a results display with a single element.
  var resultsElem = $('#results2');
  resultsElem.html(articlesResultsTemplate.render({
    articles: [this.cursor.articles[0]]
  }));
  var height1 = div.height();

  // Measure the height of a results display with two elements.
  resultsElem.html(articlesResultsTemplate.render({
    articles: [this.cursor.articles[0], this.cursor.articles[1]]
  }));
  var height2 = div.height();

  // Remove the off-screen buffer.
  div.remove();

  // Return the number of results that will fit without overflow.
  // NOTE: we add some padding since there should be some space at the bottom.
  var rootTop = this.root.offset().top;
  var windowHeight = $(window).height();
  return Math.max(1, Math.floor(
      (windowHeight - rootTop - height1 - 30) / (height2 - height1)));
};

ArticlesPage.prototype.attach = function() {
  this.attachHeader();
  this.attachPager();

  var that = this;
  $('A.scite').bind('click', function (evt) {
    evt.preventDefault();
    var article = that.findArticle($(evt.target).data('article'));
    article.scited = true;
    article.expanded = false;
    that.redisplay();
    that.rate(article, 4);
  });
  $('A.unscite').bind('click', function (evt) {
    evt.preventDefault();
    var article = that.findArticle($(evt.target).data('article'));
    article.scited = false;
    article.expanded = false;
    that.redisplay();
    that.rate(article, -1);
  });
  $('A.expand').bind('click', function (evt) {
    evt.preventDefault();
    var article = that.findArticle($(evt.target).data('article'));
    article.expanded = true;
    that.redisplay();
    that.rate(article, 1);
  });
  $('A.collapse').bind('click', function (evt) {
    evt.preventDefault();
    var article = that.findArticle($(evt.target).data('article'));
    article.expanded = false;
    that.redisplay();
  });
  $('A.arxiv').bind('click', function (evt) {
    var article = that.findArticle($(evt.target).data('article'));
    that.rate(article, 2);
  });
};

ArticlesPage.prototype.detach = function() {
  this.detachHeader();
  this.detachPager();

  $('A.scite').unbind('click');
  $('A.unscite').unbind('click');
  $('A.expand').unbind('click');
  $('A.collapse').unbind('click');
  $('A.arxiv').unbind('click');
};

// Returns the article with the given ID.
ArticlesPage.prototype.findArticle = function(id) {
  for (var i = 0; i < this.cursor.articles.length; i++) {
    if (this.cursor.articles[i].id == id) {
      return this.cursor.articles[i];
    }
  }
  unexpectedCase('no such article: ' + id);
};

// Informs the server of a new rating.
ArticlesPage.prototype.rate = function(article, rating) {
  var data = getAuthData();
  data['article_id'] = article.id;
  data['rating_action'] = rating;
  $.ajax({
      url: '/ratings?format=json',
      type: 'POST',
      data: data,
      dataType: 'json'
    }).success($.noop)
    .error(unexpectedServerError);
};
