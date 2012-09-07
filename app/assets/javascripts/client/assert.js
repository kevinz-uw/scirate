function assert(value, msg) {
  if (!value) {
    throw Error("internal error: assertion failed: " + msg);
  }
}

function unexpectedCase(msg) {
  throw Error("internal error: unexpected case: " + msg);
}
