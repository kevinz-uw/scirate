// Listen for changes to the hash change, which indicates a navigation, and
// update the UI to match it.
$(window).bind('hashchange', function(e) {
  try {
    findPage(location.hash.substring(1));
  } catch (ex) {
    unexpectedException(ex);
  }
});

// Display home when the page loads.
$(document).ready(function() {
  try {
    if ((location.hash.substring(1) == '') && (userInterests.length == 0)) {
      location.hash = '#settings';
    } else {
      findPage(location.hash.substring(1));
    }

    LogEvent('client/load');
  } catch (ex) {
    unexpectedException(ex);
  }
});

// The page currently displayed.
var curPage = null;

// Finds the page discribed in the hash string and displays it.
function findPage(hash) {
  var root = $('#content-area');

  var parts = hash.split('/');
  if (parts.length == 0) {
    displayPage(new HomePage(root, []));
  } else if (parts[0] == '') {
    displayPage(new HomePage(root, parts.slice(1)));
  } else if (parts[0] == 'new') {
    displayPage(new NewPage(root, parts.slice(1)));
  } else if (parts[0] == 'browse') {
    displayPage(new BrowsePage(root, parts.slice(1)));
  } else if (parts[0] == 'settings') {
    displayPage(new SettingsPage(root, parts.slice(1)));
  } else if (parts[0] == 'report_bug') {
    displayPage(new ReportBugPage(root, parts.slice(1)));
  } else {
    alert('unknown page: "' + hash + '"');
    findPage('');
  }
}

// Displays the given page in the content areal.
function displayPage(newPage) {
  if (curPage) {
    curPage.detach();
  }

  curPage = newPage;
  curPage.display();
  curPage.attach();
}

// Returns the authentication data that must be included on update requests.
function getAuthData() {
  var auth_param = $('meta[name=csrf-param]').attr("content");
  var auth_value = $('meta[name=csrf-token]').attr("content");
  var auth_data = {};
  auth_data[auth_param] = auth_value;
  return auth_data;
}

// Notifies the user of an error contacting the server.
function unexpectedServerError(xhr, statusText, errorThrown) {
  $('#alert-area').append(errorServerTemplate.render({
    statusText: statusText
  }));
}

// Notifies the server and user of an internal error.
function unexpectedException(ex) {
  $('#alert-area').append(errorInternalTemplate.render({
    message: ex.message
  }));

  LogEvent('client/error', undefined,
      {'browser': browserName(), 'stack': ex.stack});
}
