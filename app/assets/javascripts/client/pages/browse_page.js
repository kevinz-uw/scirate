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
  elem.html(_browseHeaderTemplate.render({
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

  elem.html(_browsePagerTemplate.render({
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

// TODO: move these to their own file.
var _browseHeaderTemplate = $.templates(
    '<h1 style="font-size: 24px;">\n' + 
      'Articles {{>first_index}} &ndash; {{>last_index}} in {{>category}}\n' +
      'from ' +
      '<span class="dropdown">\n' +
        '<a class="btn dropdown-toggle" data-toggle="dropdown" href="#">' +
          '{{>yearStr}} ' +
          '<span class="caret"></span>' +
        '</a>\n' +
        '<ul class="dropdown-menu">\n' +
          '<li><a href="#browse/{{>category}}/0" class="year"' +
                ' data-cat="0">any</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2012/0"' +
                ' class="year">2012</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2011/0"' +
                ' class="year">2011</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2010/0"' +
                ' class="year">2010</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2009/0"' +
                ' class="year">2009</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2008/0"' +
                ' class="year">2008</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2007/0"' +
                ' class="year">2007</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2006/0"' +
                ' class="year">2006</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2005/0"' +
                ' class="year">2005</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2004/0"' +
                ' class="year">2004</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2003/0"' +
                ' class="year">2003</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2002/0"' +
                ' class="year">2002</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2001/0"' +
                ' class="year">2001</a></li>\n' +
          '<li><a href="#browse/{{>category}}/2000/0"' +
                ' class="year">2000</a></li>\n' +
          '<li><a href="#browse/{{>category}}/1999/0"' +
                ' class="year">1999</a></li>\n' +
          '<li><a href="#browse/{{>category}}/1998/0"' +
                ' class="year">1998</a></li>\n' +
          '<li><a href="#browse/{{>category}}/1997/0"' +
                ' class="year">1997</a></li>\n' +
          '<li><a href="#browse/{{>category}}/1996/0"' +
                ' class="year">1996</a></li>\n' +
          '<li><a href="#browse/{{>category}}/1995/0"' +
                ' class="year">1995</a></li>\n' +
        '</ul>\n' +
      '</span>\n' +
      '{{if (month >= 0) || (year >= 0)}}\n' +
      '<span class="dropdown">\n' +
        '<a class="btn dropdown-toggle" data-toggle="dropdown" href="#">' +
          '{{>monthStr}} ' +
          '<span class="caret"></span>' +
        '</a>\n' +
        '<ul class="dropdown-menu">\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/0"' +
                ' class="month">any</a></li>\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/1/0"' +
                ' class="month">January</a></li>\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/2/0"' +
                ' class="month">February</a></li>\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/3/0"' +
                ' class="month">March</a></li>\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/4/0"' +
                ' class="month">April</a></li>\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/5/0"' +
                ' class="month">May</a></li>\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/6/0"' +
                ' class="month">June</a></li>\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/7/0"' +
                ' class="month">July</a></li>\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/8/0"' +
                ' class="month">August</a></li>\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/9/0"' +
                ' class="month">September</a></li>\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/10/0"' +
                ' class="month">October</a></li>\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/11/0"' +
                ' class="month">November</a></li>\n' +
          '<li><a href="#browse/{{>category}}/{{>year}}/12/0"' +
                ' class="month">December</a></li>\n' +
        '</ul>\n' +
      '</span>\n' +
      '{{/if}}\n' +
    '</h1>');

var _browsePagerTemplate = $.templates(
    '<ul class="pager">' +
    '  <li class="previous">\n' +
    '    <a href="#" id="articles_home"' +
          ' style="margin-right: 20px;">Home</a>\n' +
    '  </li>\n' +
    '  {{if first_index != 1}}\n' +
    '  <li class="previous">\n' +
    '    <a href="{{>prev_url}}"\n' +
    '       id="articles_prev">&larr; Previous</a>\n' +
    '  </li>\n' +
    '  {{/if}}\n' +
    '  {{if !atEnd}}\n' +
    '  <li class="next">\n' +
    '    <a href="{{>next_url}}"\n' +
    '       id="articles_next">Next &rarr;</a>\n' +
    '  </li>\n' +
    '  {{/if}}\n' +
    '</ul>');
