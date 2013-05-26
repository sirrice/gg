#<< gg/scale/scale


class gg.scale.Factory
  constructor: (@defaults) ->

  @fromSpec: (spec) ->
    sf = new gg.scale.Factory spec
    sf

  scale: (aes, type) ->
    unless aes?
      throw Error("Factory.scale(): aes was null")
    unless type?
      throw Error("Factery.scale(#{aes}): type was null")

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




