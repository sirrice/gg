#<< gg/wf/barrier

# A Barrier Transformation
#
class gg.core.BForm extends gg.wf.SyncBarrier
  @ggpackage = "gg.core.BForm"
  @log = gg.util.Log.logger @ggpackage, @ggpackage.substr(@ggpackage.lastIndexOf(".")+1)

  parseSpec: ->
    @log "XForm spec: #{JSON.stringify @spec}"

    if _.findGoodAttr(@spec, ['aes', 'aesthetic', 'mapping', 'map'], null)?
      mapSpec = _.clone @spec
      mapSpec.name = "stat-map" unless mapSpec.name?
      @map = gg.xform.Mapper.fromSpec mapSpec

    @params.putAll
      inputSchema: @extractAttr "inputSchema"
      outputSchema: @extractAttr "outputSchema"
      defaults: @extractAttr "defaults"
    @params.ensure "klassname", [], @constructor.ggpackage

    # wrap compute in a verification method
    compute = @spec.f or @compute.bind(@)
    log = @log.bind(@)
    @compute = (tableset, params) ->
      tableset = gg.core.FormUtil.addDefaults tableset, params, log
      gg.core.FormUtil.validateInput tableset, params
      compute tableset, params

  extractAttr: (attr, spec=null) ->
    spec = @spec unless spec?
    val = _.findGoodAttr spec, [attr], null
    val = @[attr] unless val?
    if _.isFunction val
      val.constructorname = @constructor.ggpackage
    val


  # Defaults for optional attributes
  defaults: (tableset, params) -> {}

  # Required input schema
  inputSchema: (tableset, params) -> []

  # Expected output schema
  outputSchema: (tableset, params) -> data.table.schema

  paneInfo: (args...) -> gg.core.FormUtil.paneInfo args...
  scalesList: (args...) -> gg.core.FormUtil.scalesList args...
  scales: (args...) -> gg.core.FormUtil.scales args...
  facetEnvs: (args...) -> gg.core.FormUtil.facetEnvs args...
  pick: (args...) -> gg.core.FormUtil.pick args...


