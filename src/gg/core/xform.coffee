#<< gg/wf/node
#<< gg/wf/exec


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
class gg.core.XForm extends gg.wf.Exec
  @ggpackage = 'gg.core.XForm'
  @log = gg.util.Log.logger @ggpackage, @ggpackage.substr(@ggpackage.lastIndexOf(".")+1)

  parseSpec: ->
    @log "XForm spec: #{JSON.stringify @spec}"

    @params.putAll
      inputSchema: @extractAttr "inputSchema"
      outputSchema: @extractAttr "outputSchema"
      defaults: @extractAttr "defaults"
    @params.ensure "klassname", [], @constructor.ggpackage

    # wrap compute in a verification method
    compute = @spec.f or @compute.bind(@)
    @compute = (table, env, params) =>
      gg.core.XForm.addDefaults table, env, params, @log
      gg.core.XForm.validateInput table, env, params, @log
      compute table, env, params

  extractAttr: (attr, spec=null) ->
    spec = @spec unless spec?
    val = _.findGoodAttr spec, [attr], null
    val = @[attr] unless val?
    if _.isFunction val
      val.constructorname = @constructor.ggpackage
    val

  #
  # Convenience functions during workflow execution
  #
  @paneInfo: (table, env) ->
    ret =
      facetX: env.get(gg.facet.base.Facets.facetXKey)
      facetY: env.get(gg.facet.base.Facets.facetYKey)
      layer: env.get "layer"
    ret

  @scales: (table, env) ->
    layer = env.get "layer"
    unless env.contains "scales"
      config = env.get "scalesconfig"
      scaleset = config.scales layer
      env.put "scales", scaleset
    env.get "scales"

  paneInfo: (args...) -> gg.core.XForm.paneInfo args...
  scales: (args...) -> gg.core.XForm.scales args...

  #
  # Schema verification functions that subclasses can override
  #

  # Defaults for optional attributes
  defaults: (table, env, params) -> {}

  # Required input schema
  inputSchema: (table, env, params) -> []

  outputSchema: (table, env, params) -> table.schema

  # throws exception if inputs don't validate with schema
  @validateInput: (table, env, params, log) ->
    return yes unless table.nrows() > 0
    iSchema = params.get "inputSchema", table, env
    missing = _.reject iSchema, (attr) -> table.contains attr
    if missing.length > 0
      log log.logname
      gg.wf.Stdout.print table, null, 5, log
      throw Error("#{params.get 'name'}: input schema did not contain #{missing.join(",")}")

  @addDefaults: (table, env, params, log) ->
    defaults = params.get "defaults", table, env
    log = @log unless log?
    log "table schema: #{table.schema.toSimpleString()}"
    log "expected:     #{JSON.stringify defaults}"
    _.each defaults, (val, col) =>
      unless table.contains col
        log "adding:      #{col} -> #{val}"
        table.addConstColumn col, val


  compute: (table, env, params) -> table




