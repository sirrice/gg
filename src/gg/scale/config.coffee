#<< gg/scale/factory
#<< gg/scale/scale


# the scale config can be used as a scale factory with
# just the default scales
#
# also creates layer specific scale factories
#
# spec:
#
# {
#   aes: SCALESPEC
# }
#
# SCALESPEC:
# {
#   aes: aes
#   type: "linear"|"log"|...
#   limit:
#   breaks:
#   label:
# }
#

class gg.scale.Config
  @log = gg.util.Log.logger "scaleConfig", gg.util.Log.ERROR

  # @param defaults:        aes -> scale
  # @param layerDefaults:   layer -> {aes -> scale}
  constructor: (@defaults, @layerDefaults)  ->

  @fromSpec: (spec, layerSpecs={}) ->

    @log "spec:      #{JSON.stringify spec}"
    @log "layerSpec: #{JSON.stringify layerSpecs}"

    # load graphic defaults
    defaults = gg.scale.Config.loadSpec spec

    # load layer defaults
    layerDefaults = {}
    _.each layerSpecs, (layerSpec, layerIdx) =>
      scalesSpec = layerSpec.scales
      layerConfig = gg.scale.Config.loadSpec scalesSpec
      layerDefaults[layerIdx] = layerConfig

    new gg.scale.Config defaults, layerDefaults

  @loadSpec: (spec) ->
    ret = {}
    if spec?
      _.each spec, (scaleSpec, aes) ->
        scaleSpec = {type: scaleSpec} if _.isString scaleSpec
        scaleSpec = _.clone scaleSpec
        scaleSpec.aes = aes
        scale = gg.scale.Scale.fromSpec scaleSpec
        ret[aes] = scale
    ret

  addLayerDefaults: (layer) ->
    layerIdx = layer.layerIdx
    layerSpec = layer.spec
    scalesSpec = layerSpec.scales
    layerConfig = gg.scale.Config.loadSpec scalesSpec
    @layerDefaults[layerIdx] = layerConfig
    gg.scale.Config.log "addLayer: #{layerConfig}"



  factoryFor: (layerIdx) ->
    spec = _.clone @defaults
    lspec = @layerDefaults[layerIdx] or {}
    _.extend spec, lspec
    gg.scale.Factory.fromSpec spec

  scale: (aes, type) -> @factoryFor().scale(aes, type)
  scales: (layerIdx) -> new gg.scale.Set @factoryFor(layerIdx)


