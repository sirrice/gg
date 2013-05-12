#<< gg/scale/scale

class gg.scale.Text extends gg.scale.Scale
  @aliases = "text"
  constructor: () ->
      @type = gg.data.Schema.ordinal
      super

  prepare: (layer, newData, aes) ->
      @pattern = layer.mappings[aes]
      @data = newData

  scale: (v, data) ->
      format = (match, key) ->
          it = data[key]
          it = it.toFixed 2 if (typeof it is 'number')
          String it
      @pattern.replace /{(.*?)}/g, format

  invert: (v) -> null

  mergeDomain: ->
  domain: ->
  range: ->




