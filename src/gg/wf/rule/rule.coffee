#
# potentially transformation rules
# A single rule takes a flow as input and outputs a flow
#
# The gg.wf.Optimizer is initialized with a set of rules that are
# serially applied
#
class gg.wf.rule.Rule
  constructor: (spec) ->
    @params = spec.params or new gg.util.Params

  run: (flow) -> flow



