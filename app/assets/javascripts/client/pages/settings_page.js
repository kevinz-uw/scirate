function SettingsPage(root, params) {
  this.root = root;
}

$.extend(SettingsPage.prototype, Page.prototype);

SettingsPage.prototype.display = function() {
  this.root.html(settingsHtmlTemplate.render({
    name: data.user.name,
    email: data.user.email,
    allow_email: data.user.allowEmail,
    primaryInterests: $.grep(data.user.interests,
        function (x) { return x.primary; }),
    secondaryInterests: $.grep(data.user.interests,
        function (x) { return !x.primary; })
  }));

  LogEvent('client/settings');
};

SettingsPage.prototype.attach = function() {
  var that = this;
  $('#inputName').bind('blur', function (evt) {
    data.setName(evt.target.value);
  });
  $('#inputAllowEmail').bind('change', function (evt) {
    data.setAllowEmail(evt.target.checked);
  });
  $('A.add-primary').bind('click', function (evt) {
    evt.preventDefault();
    data.addInterest($(evt.target).data('cat'), true,
        function () { that.redisplay() });
  });
  $('A.add-secondary').bind('click', function (evt) {
    evt.preventDefault();
    data.addInterest($(evt.target).data('cat'), false,
        function () { that.redisplay() });
  });
  $('BUTTON.remove-primary').bind('click', function (evt) {
    evt.preventDefault();
    data.removeInterest($(evt.target).data('cat'),
        function () { that.redisplay() });
  });
  $('BUTTON.remove-secondary').bind('click', function (evt) {
    evt.preventDefault();
    data.removeInterest($(evt.target).data('cat'),
        function () { that.redisplay() });
  });
  $('#done').bind('click', function (evt) {
    location.hash = '#';  // go to the home page
  });
};

SettingsPage.prototype.detach = function() {
  $('#inputName').unbind('blur');
  $('#inputAllowEmail').unbind('change');
  $('A.add-primary').unbind('click');
  $('A.add-secondary').unbind('click');
  $('BUTTON.remove-primary').unbind('click');
  $('BUTTON.remove-secondary').unbind('click');
  $('#done').unbind('click');
};
