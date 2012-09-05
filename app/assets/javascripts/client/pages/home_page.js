function HomePage(root, params) {
  this.root = root;

  // Annotate the interests with a string description of the 'last_seen' time.
  this.interests = data.user.interests;
  var now = new Date();
  for (var i = 0; i < this.interests.length; i++) {
    if (this.interests[i].last_seen) {
      var last_seen = this.interests[i].last_seen_date;
      this.interests[i].last_seen_str =
          describeDateDifferenceInDays(now, last_seen);
    }
  }
}

$.extend(HomePage.prototype, Page.prototype);

HomePage.prototype.display = function() {
  var hasPrimary = false, hasSecondary = false;
  for (var i = 0; i < this.interests.length; i++) {
    if (this.interests[i].primary) {
      hasPrimary = true;
    } else {
      hasSecondary = true;
    }
  }
  this.root.html(_homeTemplate.render({
    interests: this.interests,
    has_primary: hasPrimary,
    has_secondary: hasSecondary,
  }));
};

HomePage.prototype.attach = function() {
};

HomePage.prototype.detach = function() {
};

// TODO: move this to a new file.
var _homeTemplate = $.templates(
    '<h1>Interests</h1>' +
    '{{if has_primary}}' +
    '<h3 style="margin-top: 10px;">Primary</h3>' +
    '{{for interests}}' +
      '{{if primary}}' +
      '<div>' +
        '<div>' +
          '<b>{{>category}}</b>: ' +
          '{{if new_count > 0}}' +
          'Last read {{>last_seen_str}}. ' +
          '<a class="link" href="#new/{{>category}}/{{>new_index}}"' +
            '>view {{>new_count - new_index}} new</a> or ' +
          '<a class="link" href="#browse/{{>category}}">browse</a>' +
          '{{else}}' +
          'No new articles. ' +
          '<a class="link" href="#browse/{{>category}}">browse</a>' +
          '{{/if}}' +
        '</div>' +
      '</div>' +
      '{{/if}}' +
    '{{/for}}' +
    '{{/if}}' +
    '{{if has_secondary}}' +
    '<h3 style="margin-top: 10px;">Secondary</h3>' +
    '{{for interests}}' +
      '{{if !primary}}' +
      '<div>' +
        '{{>category}}: ' +
        '<a class="link" href="#browse/{{>category}}">browse</a>' +
      '</div>' +
      '{{/if}}' +
    '{{/for}}' +
    '{{/if}}');
