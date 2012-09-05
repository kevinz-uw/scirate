// Manifest for the analytics javascript.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require_self

$(function() {
  // Make the tabs change which pane is displayed.
  $('#tabs A').bind('click', function (evt) {
    $(evt.target).tab('show');

    var href = evt.target.href;
    var hash = href.substring(href.lastIndexOf('#'));
    if ((hash == '#users') || (hash == '#categories')) {
      $('#tf').css('display', 'none');
    } else {
      $('#tf').css('display', '');
    }
  });

  // Preserve the open tab when changing timeframe.
  $('#tf-dropdown A').bind('click', function (evt) {
    evt.preventDefault();
    window.location = evt.target.href + window.location.hash;
  });

  // Show the tab named in the URL at startup.
  var hash = window.location.hash;
  if (hash.length > 1) {
    $(hash + '-tab').tab('show');
    if ((hash == '#users') || (hash == '#categories')) {
      $('#tf').css('display', 'none');
    } else {
      $('#tf').css('display', '');
    }
  }
});
