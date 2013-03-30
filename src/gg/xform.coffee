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
#
#   defaults: Array or Function
#   inputSchema: Array or Function
#
#
# General spec transform format:
# {
#   type: XXX
#   aes: { .. mapping inserted before actual xform .., group: xxx }
#   args: { .. parameters accessible through @param .. }
# }
#
#
class gg.XForm# extends gg.wf.Exec

  constructor: (@g, @spec={}) ->

  parseSpec: ->
    spec = _.clone @spec
    console.log "xform spec:"
    console.log @spec

    inputSchema = findGood [spec.inputSchema, null]
    if inputSchema?
      unless _.isFunction inputSchema
        @inputSchema = (table, env) -> inputSchema
      else
        @inputSchema = inputSchema

    defaults = findGood [spec.defaults, null]
    if defaults?
      unless _.isFunction defaults
        console.log "uuuuugh #{JSON.stringify defaults}"
        @defaults = (table, env) -> defaults
      else
        @defaults = defaults

    @compute = spec.f or @compute
    _compute = (table, env, node) =>
      @addDefaults table, env
      @validateInput table, env
      @compute table, env, node
    spec.f = _compute

    @spec = spec


  facetGroups: (table, env) ->
    facetX: env.group(@g.facets.facetXKey, "")
    facetY: env.group(@g.facets.facetYKey, "")

  layerIdx: (table, env) ->
    layer: env.group("layer", "")

  paneInfo: (table, env) ->
    ret = @facetGroups table, env
    _.extend ret, @layerIdx(table, env)
    ret

  scales: (table, env) ->
    info = @paneInfo table, env
    @g.scales.scales(info.facetX, info.facetY, info.layer)


  # Defaults for optional attributes
  defaults: (table, env) -> {}
  # Required input schema
  inputSchema: (table, env) -> table.colNames()
  #outputSchema: (table, env) -> table.colNames()

  # throws exception if inputs don't validate with schema
  validateInput: (table, env) ->
    tableCols = table.colNames()
    iSchema = @inputSchema table, env
    missing = _.reject iSchema, (attr) -> attr in tableCols
    if missing.length > 0
      throw Error("#{@name}: input schema did not contain #{missing.join(",")}")

  addDefaults: (table, env) ->
    console.log "adding defaults of #{JSON.stringify @defaults(table, env)}"
    console.log "                   #{JSON.stringify table.colNames()}"
    _.each @defaults(table, env), (val, col) ->
      unless col in table.colNames()
        table.addConstColumn col, val

  compute: (table, env, node) -> table

  compile: -> [new gg.wf.Exec @spec]

  @fromSpec: (spec) ->
      xformName = findGood [spec.xform, "identity"]
      klass = {
      }[xformName] or gg.XForm


