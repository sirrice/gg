#<< gg/scale/scale
#<< gg/scale/categorical

class gg.scale.ColorCont extends gg.scale.Scale
  @aliases = "color_cont"
  constructor: (@spec={}) ->
    @d3Scale = d3.scale.linear()
    super

  parseSpec: ->
    super

    @startColor = @spec.startColor or d3.rgb 255, 247, 251
    @endColor = @spec.endColor or d3.rgb 2, 56, 88
    @d3Scale.range [@startColor, @endColor]

  # read only
  range: -> @d3Scale.range()



class gg.scale.Color extends gg.scale.BaseCategorical
  @aliases = "color"

  constructor: (@spec={}) ->
    super
    @d3Scale = d3.scale.category10() unless @rangeSet
    @invertScale = d3.scale.ordinal()
    @invertScale.domain(@d3Scale.range()).range(@d3Scale.domain())
    @type = gg.data.Schema.ordinal


  invert: (v) -> @invertScale v


class gg.scale.ColorScaleFuck extends gg.scale.Scale
  @aliases = "color"

  constructor: (@spec={}) ->
    super
    @isDiscrete = no
    @cScale = new gg.ColorScaleCont @spec
    @dScale = new gg.ColorScaleDisc @spec
    @type = gg.Schema.ordinal



  isNumeric: (col) -> _.every _.compact(col), _.isNumber
  myScale: -> if @isDiscrete then @dScale else @cScale
  d3: -> @myScale().d3()
  invert: (v) -> @myScale().invert v
  scale: (v) -> @myScale().scale v
  domain: (v) -> @myScale().domain v
  range: (v) -> @myScale().range v
  minDomain: -> @myScale().minDomain()
  maxDomain: -> @myScale().maxDomain()
  resetDomain: -> @myScale().resetDomain()
  minRange: -> @myScale().minRange()
  maxRange: -> @myScale().maxRange()


  clone: ->
    spec = _.clone @spec
    ret = new gg.scale.Color spec
    ret.isDiscrete = @isDiscrete
    ret.cScale = @cScale.clone()
    ret.dScale = @dScale.clone()
    ret


  mergeDomain: (interval) ->
    @log "scale.mergeDomain #{@isNumeric interval}  #{interval.length}"
    uniqs = _.uniq _.compact interval
    @isDiscrete = not (@isNumeric(uniqs) and uniqs.length > 20)

    domain = @defaultDomain interval
    @myScale().mergeDomain domain
    @domain()

  defaultDomain: (col) -> @myScale().defaultDomain col



