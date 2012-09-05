// Sends a message to the server to log the described event.
function LogEvent(activity, duration, params) {
  var postData = getAuthData();
  postData.activity = activity;
  if (duration) {
    postData['duration'] = duration;
  }
  if (params) {
    for (var key in params) {
      var value = params[key];
      if (typeof(value) == 'number') {
        if (~~value == value) {
          postData['int_' + key] = value;
        } else {
          postData['float_' + key] = value;
        }
      } else if (typeof(value) == 'string') {
        postData['str_' + key] = value;
      } else {
        unexpectedCase("type: " + typeof(value));
      }
    }
  }

  $.ajax({
      url: '/analytics?format=json',
      type: 'POST',
      data: postData,
      dataType: 'json'
    }).success($.noop)
    .error(unexpectedServerError);
}
