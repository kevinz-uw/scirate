function ReportBugPage(root, params) {
  this.root = root;
}

$.extend(ReportBugPage.prototype, Page.prototype);

ReportBugPage.prototype.display = function() {
  this.root.html(reportBugHtmlTemplate.render({}));
};

ReportBugPage.prototype.attach = function() {
  var that = this;
  $('#submit_bug').bind('click', function (evt) {
    evt.preventDefault();
    that.report($('#inputDescription').val());
    window.location.hash = '#';
  });
};

ReportBugPage.prototype.detach = function() {
  $('#submit_bug').unbind('click');
};

// Sends a bug report to the server.
ReportBugPage.prototype.report = function(desc) {
  var postData = getAuthData();
  postData.browser = browserName();
  postData.description = desc;
  $.ajax({
      url: '/report_bug?format=json',
      type: 'POST',
      data: postData,
      dataType: 'json'
    }).success($.noop)
    .error(unexpectedServerError);

  $('#alert-area').append(reportBugAlertTemplate.render({}));
};
