#
# potentially transformation rules
# A single rule takes a flow as input and outputs a flow
#
# The gg.wf.Optimizer is initialized with a set of rules that are
# serially applied
#
class gg.wf.rule.Rule
  @ggpackage = "gg.wf.rule.Rule"
  constructor: (spec={}) ->
    @params = spec.params or {}
    @params = new gg.util.Params @params
    @log = gg.util.Log.logger @constructor.ggpackage, "rule"

  run: (flow) -> flow

  #
  #
  # The following are helper functions
  #
  #

  # @param orig original node
  # @param news nodes to replace orig with
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

  # Replace node with a list of nodes.  
  # If replacements is null, or empty, removes node
  @replace: (flow, node, replacements) ->
    replacements = _.compact _.flatten [replacements]
    unless @validateReplacement node, replacements
      throw Error("Rule replacement types don't match.
        Expected #{node.type}, got #{_.map replacements (r) -> r.type}")
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
        if prev?
          flow.connectBridge prev, cur
        pre = cur

    flow

  @klasses: ->
    klasses = _.compact [
      gg.wf.rule.Server
      gg.wf.rule.RmDebug
      gg.wf.rule.Cache
      gg.wf.rule.EnvPut
      gg.wf.rule.MergeBarrier
      # errors with mergeexec
      #gg.wf.rule.MergeExec
      gg.wf.rule.RPCify
    ]
    ret = {}
    for klass in klasses
      for alias in _.flatten [klass.aliases]
        ret[alias] = klass
    ret

  @fromSpec: (spec) ->
    klass = gg.wf.rule.Rule.klasses()[spec.type]
    return null unless klass?
    new klass spec

