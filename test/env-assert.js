var assert = require("assert");
var _ = require("underscore");

assert.not = function(actual, message) {
  if (actual) {
    assert.fail(actual, false, message || "expected {actual} = false")
  }
}
assert.false = assert.not

assert.inDelta = function(actual, expected, delta, message) {
      if (!inDelta(actual, expected, delta)) {
              assert.fail(actual, expected, message || "expected {actual} to be in within *" + delta + "* of {expected}", null, assert.inDelta);
                }
};


assert.lessThan = assert.lt = function(actual, comparison, message) {
    if (!(actual < comparison)) {
        assert.fail(actual, comparison, message || "expected {actual} < {comparison}", "<");
    }
};

assert.lessThanEqual = assert.lte = function(actual, comparison, message) {
    if (!(actual <= comparison)) {
        assert.fail(actual, comparison, message || "expected {actual} <= {comparison}", "<=");
    }
};


assert.arrayEqual = function(actual, expected, message) {
  _.each(_.zip(actual, expected), function(pair) {
    assert.equal(pair[0], pair[1], message || "expected {actual} = {expected}");
  })
}
