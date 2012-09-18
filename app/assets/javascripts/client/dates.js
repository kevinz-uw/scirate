// Returns text describing d2 at the time d1.
function describeDateDifferenceInDays(d1, d2) {
  // TODO: ignore time in the future
  assert(d2.getTime() < d1.getTime(), "d1 < d2");
  var delta_hours = (d1.getTime() - d2.getTime()) / (1000 * 60 * 60);
  var delta_days = delta_hours / 24;
  if (delta_days <= 2) {
    if (d2.getDate() == d1.getDate()) {
      return 'today';
    } else if (d2.getDate() == d1.getDate() - 1) {
      return 'yesterday';
    } else {
      return '2 days ago';
    }
  }
  return Math.floor(delta_days) + ' days ago';
}

// Returns the date as a string formatted in the server-expected manner.
function formatDate(d) {
  return d.getUTCFullYear() + '-' +
      makeTwoDigits(d.getUTCMonth() + 1) + '-' +
      makeTwoDigits(d.getUTCDate()) + ' ' +
      makeTwoDigits(d.getUTCHours()) + ':' +
      makeTwoDigits(d.getUTCMinutes()) + ':' +
      makeTwoDigits(d.getUTCSeconds()) + ' UTC';
}

// Formats the given number as two digits, padding with zeros.
function makeTwoDigits(num) {
  if (num < 10) {
    return '0' + num;
  } else {
    return '' + num;
  }
}

// Map month numbers to their names.
var MONTH = {
  1: 'January',
  2: 'February',
  3: 'March',
  4: 'April',
  5: 'May',
  6: 'June',
  7: 'July',
  8: 'August',
  9: 'September',
  10: 'October',
  11: 'November',
  12: 'December'
};

// Number of days in the given month (exluding leap years).
var DAYS = {
  1: 31,
  2: 28,
  3: 31,
  4: 30,
  5: 31,
  6: 30,
  7: 31,
  8: 31,
  9: 30,
  10: 31,
  11: 30,
  12: 31
};
