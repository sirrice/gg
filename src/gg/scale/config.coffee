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
  @ggpackage = 'gg.scale.Config'
  @log = gg.util.Log.logger @ggpackage, "scaleConfig"

  # @param defaults:        aes -> scale
  # @param layerDefaults:   layer -> {aes -> scale}
  constructor: (@defaults, @layerDefaults, @specs={})  ->
    @specs.spec = {} unless @specs.spec
    @specs.layerSpecs = {} unless @specs.layerSpecs

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

    specs =
      spec: _.clone spec
      layerSpecs: _.clone layerSpecs


    new gg.scale.Config defaults, layerDefaults, specs

  toJSON: -> @specs
  @fromJSON: (json) ->
    @fromSpec json.spec, json.layerSpecs


  @loadSpec: (spec) ->
    ret = {}
    if spec?
      _.each spec, (scaleSpec, aes) =>
        scaleSpec = {type: scaleSpec} if _.isString scaleSpec
        scaleSpec = _.clone scaleSpec
        @log "resolve: #{aes} -> #{gg.core.Aes.resolve aes}"
        _.each gg.core.Aes.resolve(aes), (trueaes) ->
          scaleSpec.aes = trueaes
          scale = gg.scale.Scale.fromSpec scaleSpec
          ret[trueaes] = scale
    ret

  addLayerDefaults: (layer) ->
    layerIdx = layer.layerIdx
    layerSpec = layer.spec
    scalesSpec = layerSpec.scales
    layerConfig = gg.scale.Config.loadSpec scalesSpec
    @layerDefaults[layerIdx] = layerConfig
    @specs.layerSpecs[layerIdx] = layerSpec
    gg.scale.Config.log "addLayer: #{layerConfig}"



  factoryFor: (layerIdx) ->
    defaults = _.clone @defaults
    ldefaults = @layerDefaults[layerIdx] or {}
    _.extend defaults, ldefaults
    lspec = @specs.layerSpecs[layerIdx]
    factory = gg.scale.Factory.fromSpec defaults, lspec
    gg.scale.Config.log factory
    factory

  scale: (aes, type) -> @factoryFor().scale(aes, type)
  scales: (layerIdx) -> new gg.scale.Set @factoryFor(layerIdx)


