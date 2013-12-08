#<< gg/scale/scale
#<< gg/scale/categorical

class gg.scale.ColorCont extends gg.scale.Scale
  @ggpackage = 'gg.scale.ColorCont'
  @aliases = ["color_cont", "colorcont"]
  constructor: (@spec={}) ->
    @d3Scale = d3.scale.linear().interpolate(d3.interpolateLab)
    @type = data.Schema.numeric

    range = [d3.rgb(255, 255, 255), d3.rgb('steelblue')]#2, 56, 88)]
    range = @spec.range if @spec.range?
    @d3Scale.range range
    super


  # read only
  range: -> @d3Scale.range()



class gg.scale.Color extends gg.scale.BaseCategorical
  @ggpackage = 'gg.scale.Color'
  @aliases = "color"

  constructor: (@spec={}) ->
    super
    @d3Scale = d3.scale.category10() unless @rangeSet
    @invertScale = d3.scale.ordinal()
    @invertScale.domain(@d3Scale.range()).range(@d3Scale.domain())
    @type = data.Schema.ordinal


  invert: (v) -> @invertScale v

  scale: (v) -> @d3Scale v

