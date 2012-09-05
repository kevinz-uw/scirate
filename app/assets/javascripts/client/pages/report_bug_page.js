function ReportBugPage(root, params) {
  this.root = root;
}

$.extend(ReportBugPage.prototype, Page.prototype);

ReportBugPage.prototype.display = function() {
  this.root.html(_reportBugTemplate.render({}));
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

  $('#alert-area').append(_reportedBugTemplate.render({}));
};

// TODO: move these to new files.
var _reportBugTemplate = $.templates(
    '<h1 style="font-size: 24px;">Report a bug</h1>' +
    '<form class="form-horizontal">' +
      '<span class="help-block">Please describe the bug that you encountered:' +
      '<ul>' +
      '<li>What were you doing when the bug occurred?</li>' +
      '<li>What was the bug?</li>' +
      '<li>What did you expect the page to have done if it was working' +
      ' correctly?</li>' +
      '</ul>' +
      '</span>' +
      '<textarea id="inputDescription"' +
        ' style="margin-top: 10px; width: 580px; height: 200px;"></textarea>' +
      '<div style="margin-top: 20px;">' +
      '<button type="btn" class="btn btn-primary" id="submit_bug">' +
        'Report' +
      '</button>' +
      '</div>' +
    '</form>'
    );

var _reportedBugTemplate = $.templates(
    '<div class="alert alert-info">' +
    '<button type="button" class="close" data-dismiss="alert">×</button>' +
    '<strong>Thank you!</strong> This bug has been reported. ' +
    'We will get straight to work fixing this sisue.' +
    '</div>');
