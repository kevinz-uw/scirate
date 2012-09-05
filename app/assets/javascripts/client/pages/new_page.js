function NewPage(root, params) {
  this.category = params[0];
  this.interest = data.findInterest(this.category);
  this.firstIndex = (params.length > 1) ? parseInt(params[1]) : 0;
  this.initArticles(root, this.interest);
}

$.extend(NewPage.prototype, ArticlesPage.prototype);

NewPage.prototype.displayHeader = function(elem, firstIndex, lastIndex) {
  this.lastIndex = lastIndex;
  elem.html(_newHeaderTemplate.render({
    category: this.category,
    first_index: firstIndex + 1,
    last_index: lastIndex + 1,
    length: this.interest.articles.length
  }));
};

NewPage.prototype.displayPager = function(elem, firstIndex, lastIndex, atEnd) {
  elem.html(_newPagerTemplate.render({
    category: this.category,
    first_index: firstIndex + 1,
    last_index: lastIndex + 1,
    length: this.interest.articles.length,
    prev_index: Math.max(0, firstIndex - this.numVisible)
  }));
};

NewPage.prototype.attachHeader = function() {};

NewPage.prototype.attachPager = function() {
  var that = this;
  $('#articles_prev').bind('click', function (evt) {
    // default action will cause an update
    window.scrollTo(0, 0);
  });
  $('#articles_next').bind('click', function (evt) {
    // default action will cause an update
    window.scrollTo(0, 0);
  });
  $('#articles_skip').bind('click', function (evt) {
    evt.preventDefault();
    that.skip();
    window.scrollTo(0, 0);
  });
  $('#articles_done').bind('click', function (evt) {
    evt.preventDefault();
    that.skip();  // has the same effect currently
    window.scrollTo(0, 0);
  });

  // Record that the articles on this page are no longer new.
  this.interest.new_index =
      Math.max(this.interest.new_index, this.firstIndex);

  // Record that the user has seen these articles. Even if they do not page
  // through them all, we will not bother them about these again.
  if (!this.interest.updated) {
    this.interest.updated = true;  // only do this once

    $.ajax({
        url: '/interests/' + this.interest.id + '?format=json&last_seen',
        type: 'PUT',
        data: getAuthData(),
        dataType: 'json'
      }).success($.noop)
      .error(unexpectedServerError);
  }
};

NewPage.prototype.detachHeader = function() {};

NewPage.prototype.detachPager = function() {
  $('#articles_prev').unbind('click');
  $('#articles_next').unbind('click');
  $('#articles_skip').unbind('click');
  $('#articles_done').unbind('click');
};

// Called when the user clicks the skip button.
NewPage.prototype.skip = function() {
  // Record that all the articles are no longer new.
  this.interest.new_count = 0;
  if (!data.hasNewArticles()) {
    this.showWinMessage();
  }

  // Display the home page.
  location.hash = '#';

  LogEvent('client/new', undefined, {
      'total': this.interest.articles.length,
      'seen': this.lastIndex + 1,
      'scited': NewPage.countScited(this.interest.articles)
    });
}

// Congratulates the user on getting up to date.
NewPage.prototype.showWinMessage = function () {
  $('#alert-area').append(_winTemplate.render({
    treat: Math.floor(Math.random() * 4)
  }));
};

// Counts the number of the given articles that were scited.
NewPage.countScited = function(articles) {
  var count = 0;
  for (var i = 0; i < articles.length; i++) {
    if (articles[i].scited) {
      count++;
    }
  }
  return count;
};

// TODO: move these to new files.
var _newHeaderTemplate = $.templates(
    '<h1 style="font-size: 24px;">\n' + 
    'New Articles {{>first_index}} &ndash; {{>last_index}} of {{>length}}' +
    ' in {{>category}}\n' +
    '</h1>');

var _newPagerTemplate = $.templates(
    '<ul class="pager">' +
    '  {{if first_index != 1}}\n' +
    '  <li class="previous">\n' +
    '    <a href="#new/{{>category}}/{{>prev_index}}"\n' +
    '       id="articles_prev">&larr; Previous</a>\n' +
    '  </li>\n' +
    '  {{/if}}\n' +
    '  {{if last_index != length}}\n' +
    '  <li class="next">\n' +
    '    <a href="#new/{{>category}}/{{>last_index}}"\n' +
    '       id="articles_next">Next &rarr;</a>\n' +
    '  </li>\n' +
    '  <li class="next">\n' +
    '    <a href="#" id="articles_skip"' +
          ' style="margin-right: 20px;">Skip ' +
          '{{>last_index+1}}&ndash;{{>length}}</a>\n' +
    '  </li>\n' +
    '  {{else}}\n' +
    '  <li class="next">\n' +
    '    <a href="#" id="articles_done">Done</a>\n' +
    '  </li>\n' +
    '  {{/if}}\n' +
    '</ul>');

var _winTemplate = $.templates(
    '<div class="alert alert-success">' +
    '<button type="button" class="close" data-dismiss="alert">×</button>' +
    '<strong>Congratulations!</strong> You are completely up to date. ' +
    '{{if treat == 0}}' +
    '  You deserve a cookie.' +
    '{{else if treat == 1}}' +
    '  Enjoy a relaxing walk.' +
    '{{else if treat == 2}}' +
    '  Is it coffee time now?' +
    '{{else if treat == 3}}' +
    '  I wish I could be more like you... I mean, if I wasn\'t a computer.' +
    '{{else}}' +
    '{{/if}}' +
    '</div>');
