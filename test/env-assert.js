var assert = require("assert");

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

assert.lessThan = assert.lt = function(actual, comparison, message) {
    if (!(actual <= comparison)) {
        assert.fail(actual, comparison, message || "expected {actual} <= {comparison}", "<=");
    }
};

