#<< gg/scale/scale


class gg.scale.Factory
  @ggpackage = 'gg.scale.Factory'


  constructor: (@defaults) ->

  @fromSpec: (defaults) ->
    sf = new gg.scale.Factory defaults
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

    scale.type = type if _.isSubclass scale, gg.scale.Identity
    scale

  scales: (layerIdx) -> new gg.scale.Set @
  toString: ->
    arr = _.map @defaults, (scale, aes) ->
      "\t#{aes} -> #{scale.toString()}"
    arr.join("\n")

  toJSON: ->
    json = {}
    _.each @defaults, (scale, aes) ->
      json[aes] = scale.toJSON()
    json

  @fromJSON: (json) ->
    defaults = {}
    _.each json, (scaleJSON, aes) ->
      defaults[aes] = gg.scale.Scale.fromJSON scaleJSON
    new gg.scale.Factory defaults






