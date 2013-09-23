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

  constructor: (@spec={}) ->
    @premap = @postmap = null
    super

  parseSpec: ->
    @log "XForm spec: #{JSON.stringify @spec}"

    # pre-xform aesthetic mapping
    if _.findGoodAttr(@spec, gg.xform.Mapper.attrs, null)?
      mapSpec = _.clone @spec
      @premap = gg.xform.Mapper.fromSpec mapSpec

    if @spec.postmap?
      postmapSpec = {aes: @spec.postmap}
      @postmap = gg.xform.Mapper.fromSpec @spec.postmap

    @params.putAll
      inputSchema: @extractAttr "inputSchema"
      outputSchema: @extractAttr "outputSchema"
      defaults: @extractAttr "defaults"
    @params.ensure "klassname", [], @constructor.ggpackage

    # wrap compute in a verification method
    compute = @spec.f or @compute.bind(@)
    log = @log.bind(@)
    @compute = (data, params) ->
      gg.core.FormUtil.addDefaults data, params, log
      gg.core.FormUtil.validateInput data, params, log
      compute data, params

  extractAttr: (attr, spec=null) ->
    spec = @spec unless spec?
    val = _.findGoodAttr spec, [attr], null
    val = @[attr] unless val?
    if _.isFunction val
      val.constructorname = @constructor.ggpackage
    val


  #
  # Schema verification functions that subclasses can override
  #

  # Defaults for optional attributes
  defaults: (data, params) -> {}

  # Required input schema
  inputSchema: (data, params) -> []

  # Expected output schema
  outputSchema: (data, params) -> data.table.schema


  paneInfo: (args...) -> gg.core.FormUtil.paneInfo args...
  scales: (args...) -> gg.core.FormUtil.scales args...

  compile: ->
    nodes = []
    nodes.push @premap.compile() if @premap?
    nodes.push super
    nodes.push @postmap.compile() if @postmap?
    _.compact _.flatten nodes
