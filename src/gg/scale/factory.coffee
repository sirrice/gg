#<< gg/scale/scale


class gg.scale.Factory
  constructor: (@defaults) ->
    console.log "gg.ScaleFactory new:\n#{@toString()}"

  @fromSpec: (spec) ->
    sf = new gg.scale.Factory spec
    sf

  scale: (aes, type) ->
    unless aes?
      throw Error()
    unless type?
      throw Error()

    scale =
      if aes of @defaults
        @defaults[aes].clone()
      else
        gg.scale.Scale.defaultFor aes, type

    scale

  scales: (layerIdx) -> new gg.scale.Set @
  toString: ->
    arr = _.map @defaults, (scale, aes) ->
      "\t#{aes} -> #{scale.toString()}"
    arr.join("\n")




