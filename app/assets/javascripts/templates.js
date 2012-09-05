/**
 * Adds helper functions to be used in jsrender templates.
 */

var DAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
var MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug',
              'Sep', 'Nov', 'Dec'];

$.views.helpers({

  // Returns an array containing the given field from each object in an array.
  pluck: function(arr, field) {
    var res = []
    for (var i = 0; i < arr.length; i++) {
      res.push(arr[i][field]);
    }
    return res;
  },

  // Joins the given array using the given separator string.
  join: function(arr, sep) {
    return arr.join(sep);
  },

  // Formats a full date and time in the local timezone.
  dateAndTime: function(date) {
    // Like date.toUTCString but in local timezone.
    return DAYS[date.getDay()] + ', ' + date.getDate() + ' ' +
        MONTHS[date.getMonth()] + ' ' + date.getFullYear() + ' ' +
        date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds();
  }
});
