#<< gg/wf/node


#
# An XForm defines required input and output schemas.
# It throws an exception if the input data does not adhere to the schema.
# All schema mapping happens external to an XForm (not completely true,
# see `Xforms as workflow nodes`)
#
# XForms also define default schema values, which will be used to fill
# in the input table.
#
# Global State
# ------------
#
# XForms are tied to an instance of a layer and has accessors for
#
# 1) which facet it belongs to
# 2) which layer it belongs to
# 3) the "correct" set of scales for its aesthetics -- this depends on
#    the stage of the workflow and which scales training has happened
#
#
# WRONG::: XForms as workflow nodes
# ------------------------
# For convenience, XForm is a workflow Exec node
#
# NOTE: the XForm should not be used directly.  Instead, workflow nodes should be
#       accessed via the @nodes() call, which returns [@] by default.  This allows
#       more complex statistics return a series of workflow nodes
#       A typical series may be: mapping -> split -> exec -> join
#
#
#
# Spec:
# {
#   f: Compute Function
#   params: {
#      [attr: Object or Function]*
#   }
#   ... other gg.wf.Node spec entries ...
# }
#
#
class gg.XForm

  constructor: (@g, @spec={}) ->
    #unless _.isSubclass @g, gg.Graphic
    #  throw Error("Xform passed non-graphic as first argument")

    # before executing the operator, we will add the table, environment and node
    # objects to this state variable, so they can be accessed from the compute
    # function
    #
    # The state variable is released after the operator exits
    @state = {}

    @params = {}

  parseSpec: ->

    spec = _.clone @spec
    console.log "XForm spec: #{JSON.stringify spec}"

    @inputSchema = @extractAttr "inputSchema"
    @defaults = @extractAttr "defaults"

    @compute = spec.f or @compute
    @spec = spec

  extractAttr: (attr, spec=null) ->
    spec = @spec unless spec?
    val = findGoodAttr spec, [attr], null
    if val?
      unless _.isFunction val
        (table, env) -> val
      else
        val
    else
      @[attr]


  # Convenience functions during workflow execution
  # All functions take (table, env) as input
  facetGroups: (table, env) ->
    env = @state.env unless env
    {
      facetX: env.group(@g.facets.facetXKey, "")
      facetY: env.group(@g.facets.facetYKey, "")
    }

  layerIdx: (table, env) ->
    env = @state.env unless env
    {layer: env.group("layer", "")}

  paneInfo: (table, env) ->
    table = @state.table unless table?
    env = @state.env unless env
    ret = @facetGroups table, env
    _.extend ret, @layerIdx(table, env)
    ret

  scales: (table, env) ->
    table = @state.table unless table?
    env = @state.env unless env
    info = @paneInfo table, env
    @g.scales.scales(info.facetX, info.facetY, info.layer)

  # parameter accessor
  #
  param: (table, env, attr, defaultVal=null) ->
    table = @state.table unless table?
    env = @state.env unless env

    if attr of @params
      ret = @params[attr]
    else
      if attr of @
        ret = @[attr]
      else
        return defaultVal

    if _.isFunction ret then ret(table, env) else ret

  # Defaults for optional attributes
  defaults: (table, env) -> {}

  # Required input schema
  inputSchema: (table, env) -> table.colNames()

  # throws exception if inputs don't validate with schema
  validateInput: (table, env) ->
    tableCols = table.colNames()
    iSchema = @param table, env, "inputSchema"
    missing = _.reject iSchema, (attr) -> attr in tableCols
    if missing.length > 0
      throw Error("#{@name}: input schema did not contain #{missing.join(",")}")

  # remove rows where a required attribute is null/nan/undefined
  filterInput: (table, env) ->
    iSchema = @param table, env, "inputSchema"
    scales = @scales table, env
    info = @paneInfo table, env
    scales = @g.scales.facetScales info.facetX, info.facetY
    console.log scales
    table.filter (row) ->
      _.every iSchema, (attr) ->
        val = row.get(attr)
        isDefined = not(
          _.isNaN(val) or _.isNull(val) or _.isUndefined(val))
        #scale = scales.scale(attr, table.schema.type attr)
        isDefined #and scale.valid(val)


  addDefaults: (table, env) ->
    defaults = @param table, env, "defaults"
    console.log "adding defaults of #{JSON.stringify defaults}"
    console.log "                   #{JSON.stringify table.colNames()}"
    _.each defaults, (val, col) ->
      unless col in table.colNames()
        console.log "adding default    #{col} -> #{val}"
        table.addConstColumn col, val

  compute: (table, env, node) -> table



  # Wraps @compute to validate inputs and add defaults
  compile: ->
    spec = _.clone @spec
    _compute = (table, env, node) =>
      table = table.cloneDeep()
      @state =
        table: table
        env: env
        node: node
      @addDefaults table, env
      @validateInput table, env
      table = @filterInput table, env
      @compute table, env, node
    spec.f = _compute
    node = new gg.wf.Exec spec
    node.on "done", () =>
      @state = {}
    [node]

  @fromSpec: (spec) ->
      xformName = findGood [spec.xform, "identity"]
      klass = {
      }[xformName] or gg.XForm


  log: (text) ->
    console.log "#{@spec.name} #{@constructor.name}:\t#{text}"
