function Page() { /* unused */ }

// Updates the UI to match the current data.
Page.prototype.redisplay = function() {
  this.detach();
  this.display();
  this.attach();
};

Page.prototype.display = function() {
  unexpectedCase("display not implemented");
};

Page.prototype.attach = function() {
  unexpectedCase("attach not implemented");
};

Page.prototype.detach = function() {
  unexpectedCase("attach not implemented");
};
