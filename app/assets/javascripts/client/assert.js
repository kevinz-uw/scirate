function assert(value, msg) {
  if (!value) {
    throw Exception("internal error: assertion failed: " + msg);
  }
}

function unexpectedCase(msg) {
  throw Exception("internal error: unexpected case: " + msg);
}
