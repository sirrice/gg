#<< gg/wf/robarrier
#<< gg/wf/barrier

# A Barrier Transformation
#
class gg.core.BForm extends gg.wf.SyncROBarrier
  @ggpackage = "gg.core.BForm"
  @log = gg.util.Log.logger @ggpackage, @ggpackage.substr(@ggpackage.lastIndexOf(".")+1)

  parseSpec: ->
    @log "XForm spec: #{JSON.stringify @spec}"

    @params.putAll
      inputSchema: @extractAttr "inputSchema"
      outputSchema: @extractAttr "outputSchema"
      defaults: @extractAttr "defaults"
      keys: ['facet-x', 'facet-y', 'layer']
    @params.ensure "klassname", [], @constructor.ggpackage

    # wrap compute in a verification method
    f = @spec.f
    f ?= @compute.bind @
    FormUtil = gg.core.FormUtil
    makecompute = (log) ->
      (pairtable, params) ->
        #pairtable = FormUtil.addDefaults pairtable, params, log
        #FormUtil.validateInput pairtable, params
        f pairtable, params
    @params.put 'compute', makecompute(@log)
    super

  extractAttr: (attr, spec=null) ->
    spec = @spec unless spec?
    val = _.findGoodAttr spec, [attr], null
    val = @[attr] unless val?
    if _.isFunction val
      val.constructorname = @constructor.ggpackage
    val


  # Defaults for optional attributes
  defaults: (pairtable, params) -> {}

  # Required input schema
  inputSchema: (pairtable, params) -> []

  # Expected output schema
  outputSchema: (pairtable, params) -> pairtable.left().schema


