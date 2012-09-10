function HomePage(root, params) {
  this.root = root;

  // Annotate the interests with a string description of the 'last_seen' time.
  this.interests = data.user.interests;
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
  this.root.html(homeHtmlTemplate.render({
    interests: this.interests,
    has_primary: hasPrimary,
    has_secondary: hasSecondary,
  }));
};

HomePage.prototype.attach = function() {
};

HomePage.prototype.detach = function() {
};
