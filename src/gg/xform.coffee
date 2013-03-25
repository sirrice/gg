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
# XForms as workflow nodes
# ------------------------
# For convenience, XForm is a workflow Exec node
#
# NOTE: the XForm should not be used directly.  Instead, workflow nodes should be
#       accessed via the @nodes() call, which returns [@] by default.  This allows
#       more complex statistics return a series of workflow nodes
#       A typical series may be: mapping -> split -> exec -> join
#
#
class gg.XForm extends gg.wf.Exec

  constructor: (@g, @spec={}) ->
    super @spec

    # now wrap @compute with a validation step
    _compute = @compute
    @compute = (table, env, node) =>
      @validateInput table, env
      @addDefaults table, env
      _compute table, env, node

  facetGroups: (env) ->
    facetX: env.group(@g.facets.facetXKey, "")
    facetY: env.group(@g.facets.facetYKey, "")

  layerIdx: (env) ->
    layer: env.group("layer", "")

  paneInfo: (env) ->
    facetX: env.group(@g.facets.facetXKey, "")
    facetY: env.group(@g.facets.facetYKey, "")
    layer: env.group("layer", "")

  # Defaults for optional attributes
  defaults: (table, env) -> {}
  # Required input schema
  inputSchema: (table, env) -> table.colNames()
  outputSchema: (table, env) -> table.colNames()

  # throws exception if inputs don't validate with schema
  validateInput: (table, env) ->
    tableCols = table.colNames()
    iSchema = @inputSchema table, env
    missing = _.reject iSchema, (attr) -> attr of tableCols
    if missing.length > 0
      throw Error("#{@name}: input schema did not contain #{missing.join(",")}")

  addDefaults: (table, env) ->
    _.each @defaults(table, env), (val, col) ->
      unless col of table.colNames
        table.addConstColumn col, name


  compile: -> [@]

  @fromSpec: (spec) ->
      xformName = findGood [spec.xform, "identity"]
      klass = {
      }[xformName] or gg.XForm


