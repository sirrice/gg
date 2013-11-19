#<< gg/scale/scale

class gg.scale.Text extends gg.scale.Scale
  @ggpackage = 'gg.scale.Text'
  @aliases = "text"
  constructor: () ->
      @type = data.Schema.ordinal
      super

  scale: (v) ->
    String v
    #format = (match, key) ->
    #  it = data[key]
    #  it = it.toFixed 2 if (typeof it is 'number')
    #  String it
    #@pattern.replace /{(.*?)}/g, format

  invert: (v) -> String v

  @defaultDomain: (col) -> [null, null]
  mergeDomain: ->
  domain: -> [null, null]
  range: -> [null, null]




