#<< gg/wf/rule/rule

# Rule that replaces individual nodes in the workflow
# with a linear sequence of new nodes (doesn't change branching structure)
#
class gg.wf.rule.Node extends gg.wf.rule.Rule

  constructor: () ->

  # Subclasses override this method
  # @return node or array of nodes to replace this node in the workflow
  #         return null if node should be removed
  compute: (node) -> node


  run: (flow) ->
    _.each flow.nodes(), (node) =>
      replacements = @compute node
      replacements = [replacements] unless _.isArray replacements
      replacements = _.compact replacements

      gg.wf.rule.Node.replace flow, node, replacements

    flow

  @validateReplacement: (orig, news) ->
    return yes unless news.length > 0
    typeToClass = (type) ->
      switch type
        when "barrier" then "barrier"
        when "multicast" then "multicast"
        else "normal"

    origClass = typeToClass orig
    #typeToClass(_.first news) == typeToClass(_.last news) == origClass
    _.all news, (n) -> typeToClass(n) == origClass

  @replace: (flow, node, replacements) ->
    unless @validateReplacement node, replacements
      throw Error("Rule replacement types don't match.
        Expected #{node.type}, got #{_.map replacements (r) -> r.type}")
    return if replacements.length is 0
    return if replacements.length is 1 and replacements[0] == node

    # store node's original input and output edges
    cs = flow.children(node)
    bcs = flow.bridgedChildren(node)
    ps = flow.parents(node)
    bps = flow.bridgedParents(node)
    flow.rm node

    cur = prev = null
    lastnonbarrier = null
    for cur in replacements
      if prev?
        # connect it
        flow.connect prev, cur
      else
        # connect to parents
        _.each ps,  (p) => flow.connect p, cur
        _.each bps, (p) => flow.connectBridge p, cur

      unless cur.type == "barrier"
        lastnonbarrier = cur
      prev = cur

    # connect with children
    if lastnonbarrier?
      _.each cs, (c) -> flow.connect cur, c
      _.each bcs, (c) -> flow.connectBridge cur, c

    # connect interior bridges e.g., exec -> barrier -> exec
    prev = null
    for cur in replacements
      unless cur.type == "barrier"
        flow.connectBridge prev, cur
        pre = cur

    flow
