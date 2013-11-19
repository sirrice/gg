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
class gg.core.XForm extends gg.wf.SyncExec
  @ggpackage = 'gg.core.XForm'
  @log = gg.util.Log.logger @ggpackage, @ggpackage.substr(@ggpackage.lastIndexOf(".")+1)

  constructor: (@spec={}) ->
    @premap = @postmap = null
    super

  parseSpec: ->
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
    compute = @params.get('compute') or @compute.bind(@)
    log = @log.bind(@)
    @compute = (pt, params) ->
      pt = gg.core.FormUtil.addDefaults pt, params, log
      gg.core.FormUtil.validateInput pt, params, log
      log "running xform compute"
      compute pt, params

    super

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
  ensureScales: (pairtable, params) -> gg.core.FormUtil.ensureScales pairtable, params, @log

  scales: (pairtable, params) -> gg.core.FormUtil.scales pairtable, params, @log

  # Defaults for optional attributes
  defaults: (pt, params) -> {}

  # Required input schema
  inputSchema: (pt, params) -> []

  # Expected output schema
  outputSchema: (pt, params) -> pt.leftSchema()

  compile: ->
    nodes = []
    nodes.push @premap.compile() if @premap?
    nodes.push super
    nodes.push @postmap.compile() if @postmap?
    _.compact _.flatten nodes
