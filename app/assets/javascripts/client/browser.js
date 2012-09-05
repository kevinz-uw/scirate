function browserName() {
  if (navigator.userAgent.indexOf('Chrome') >= 0) {
    return 'Chrome';
  }
  if (navigator.vendor.indexOf('Apple') >= 0) {
    return 'Safari';
  }
  if (navigator.userAgent.indexOf('Firefox') >= 0) {
    return 'Firefox';
  }
  if (navigator.userAgent.indexOf('MSIE') >= 0) {
    return 'IE';
  }
  if (navigator.userAgent.indexOf('Gecko') >= 0) {
    return 'Mozilla';
  }
  return 'unknown';
}
