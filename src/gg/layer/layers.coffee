#<< gg/util/util
#<< gg/layer/layer
#<< gg/layer/shorthand
#<< gg/layer/array

class gg.layer.Layers
    constructor: (@g, @spec) ->
      @layers = []
      @log = gg.util.Log.logger "Layers", gg.util.Log.WARN
      @parseSpec()

    parseSpec: ->
      _.each @spec, (layerspec) => @addLayer layerspec

    # @return [ [node,...], ...] a list of nodes for each layer
    compile: ->
      _.map @layers, (l) =>
        nodes = l.compile()
        @log "compile layer #{l.layerIdx}"
        _.each nodes, (node) =>
          @log "compile node: #{node.name}"
        nodes

    getLayer: (layerIdx) ->
      if layerIdx >= @layers.length
        throw Error("Layer with idx #{layerIdx} does not exist.
          Max layer is #{@layers.length}")
      @layers[layerIdx]

    get: (layerIdx) -> @getLayer layerIdx

    addLayer: (layerOrSpec) ->
      layerIdx = @layers.length

      if _.isSubclass layerOrSpec, gg.layer.Layer
        layer = layerOrSpec
      else
        spec = _.clone layerOrSpec
        spec.layerIdx = layerIdx
        layer = gg.layer.Layer.fromSpec @g, spec

      layer.layerIdx = layerIdx
      @layers.push layer







