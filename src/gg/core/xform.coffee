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
class gg.core.XForm
  @ggpackage = 'gg.core.XForm'

  constructor: (@spec={}) ->

    # Before executing the operator, we will add the
    # * table,
    # * environment
    # * node object
    #
    # to this state variable, so they can be accessed from
    # the compute function
    #
    # The state variable is released after the operator exits
    #
    # All of the state is encapsulated in @spec, @state, @params
    #
    @params = new gg.util.Params
    logname = "#{@spec.name} #{@constructor.name}"
    @log = gg.util.Log.logger logname,  gg.util.Log.DEBUG unless @log?

    console.log @spec
    @parseSpec()


  parseSpec: ->
    @log "XForm spec: #{JSON.stringify @spec}"

    @params.merge @spec.params

    @params.putAll
      inputSchema: @extractAttr "inputSchema"
      outputSchema: @extractAttr "outputSchema"
      defaults: @extractAttr "defaults"

    # add all the necessary during execution state here

    @compute = @spec.f or @compute

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
      console.log "XFORM.GET SCALES #{layer}"
      config = env.get "scalesconfig"
      scaleset = config.scales layer
      console.log config
      console.log scaleset
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
  @validateInput: (table, env, params) ->
    iSchema = params.get "inputSchema", table, env
    missing = _.reject iSchema, (attr) -> table.contains attr
    if missing.length > 0
      gg.wf.Stdout.print table, null, 5, gg.util.Log.logger("err")
      throw Error("#{params.get 'name'}: input schema did not contain #{missing.join(",")}")

  @addDefaults: (table, env, params) ->
    defaults = params.get "defaults", table, env
    log = gg.util.Log.logger(params.get 'name')
    log "expected:    #{JSON.stringify defaults}"
    log "table attrs: #{JSON.stringify table.schema.attrs()}"
    _.each defaults, (val, col) =>
      unless table.contains col
        log "adding:      #{col} -> #{val}"
        table.addConstColumn col, val

  compute: (table, env, params) -> table


  # Wraps @compute to validate inputs and add defaults
  #
  # The complete state necessary to execute compute must be
  # self contained and easily pickleable
  compile: ->
    spec = _.clone @spec
    log = @log
    _compute = (table, env, params) ->
      log "table schema: #{table.schema.toSimpleString()}"

      table = table.cloneDeep()

      gg.core.XForm.addDefaults table, env, params
      gg.core.XForm.validateInput table, env, params
      #table = @filterInput table, env
      compute = params.get '__compute__'
      compute table, env, params

    spec.params = @params.clone()
    spec.params.put 'klassname', @constructor.ggpackage
    spec.params.put 'compute', _compute
    spec.params.put '__compute__', (args...) => @compute args...
    spec.params.put 'name', spec.name or @constructor.name

    unless spec.params.get('klassname')?
      console.log @
      throw Error("No classname")
    node = new gg.wf.Exec spec
    [node]




