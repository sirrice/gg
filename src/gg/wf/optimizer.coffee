
# Takes a flow as input and outputs a flow that may have swapped nodes for
# other implementations or subflows for single nodes.
#
class gg.wf.Optimizer
  constructor: (@rules) ->
    @rules = [@rules] unless _.isArray @rules

  run: (flow) ->
    for rule in @rules
      flow = rule.run flow
    flow

    
