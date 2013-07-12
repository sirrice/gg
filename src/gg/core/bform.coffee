#<< gg/wf/barrier

# A Barrier Transformation
#
class gg.core.BForm extends gg.wf.Barrier
  @ggpackage = "gg.core.BForm"
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
    @compute = (datas, params) =>
      gg.core.FormUtil.multiAddDefaults datas, params, @log
      gg.core.FormUtil.multiValidateInput datas, params
      compute datas, params

  extractAttr: (attr, spec=null) ->
    spec = @spec unless spec?
    val = _.findGoodAttr spec, [attr], null
    val = @[attr] unless val?
    if _.isFunction val
      val.constructorname = @constructor.ggpackage
    val


  # Defaults for optional attributes
  defaults: (data, params) -> {}

  # Required input schema
  inputSchema: (data, params) -> []

  # Expected output schema
  outputSchema: (data, params) -> data.table.schema

  paneInfo: (args...) -> gg.core.FormUtil.paneInfo args...
  scalesList: (args...) -> gg.core.FormUtil.scalesList args...
  scales: (args...) -> gg.core.FormUtil.scales args...
  facetEnvs: (args...) -> gg.core.FormUtil.facetEnvs args...
  pick: (args...) -> gg.core.FormUtil.pick args...


