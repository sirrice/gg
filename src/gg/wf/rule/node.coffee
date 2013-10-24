#<< gg/wf/rule/rule

# Rule that replaces individual nodes in the workflow
# with a linear sequence of new nodes (doesn't change branching structure)
#
class gg.wf.rule.Node extends gg.wf.rule.Rule

  constructor: (spec={}) ->
    super

  # Subclasses override this method
  # @return node or array of nodes to replace this node in the workflow
  #         return null if node should be removed
  compute: (node) -> node


  run: (flow) ->
    _.each flow.nodes(), (node) =>
      replacements = @compute node
      replacements = _.flatten [replacements]
      replacements = _.compact replacements

      gg.wf.rule.Rule.replace flow, node, replacements

    flow
