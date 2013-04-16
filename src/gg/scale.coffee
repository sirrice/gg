#<< gg/util



#
# Scales define a scaling and aesthetic mapping for a given aesthetic:
#
#   original domain -> transformed domain -> aesthetic range
#
# For example:
#
#   population -> log(population) -> x pixel coordinate
#
# The transformations are respectively called
#
# 1) scaling transform
#
#
# Aesthetics include:
#
#   x, y, x1, y1, x2, y2, r, fill, stroke, stroke-color, opacity, etc etc
#
# A continuous transformation is an invertable mapping such as:
#
#   log(v)
#   pow(exp)
#   linear(v)
#   sin(v)
#   identity(v)
#
# A discrete transformatino is from one set of categorical values to another:
#
#   [a,b,c] -> [x,y,z]
#   identity
#
# In addition, scales are responsible for generating the label value when rendering guides.
# These labels go from the final aesthetic value to the original domain.
#
#
# name
# limits: limits or range
# expand: [int, int].  add spacing on axis. multiplies by expand[0], adds/subs by expand[1]
# domain
# range
# breaks
# aesthetic
# @aesthetics
#
#
# expand: (limits) -> sane limits
# breaks: (scale, limits) -> breaks or invert limits via scale, compute breaks, transform via scale
# train
#
#
# spec:
#
# {
#   aes:
#   type
#   limits
#   range
#   breaks
#   label
#  }
#
class gg.Scale
  @aliases = "scale"
  _id: 0
  constructor: (@spec={}) ->
    @aes = null


    # Whether or not the domain/range was set from the Spec
    # -> don't update at all
    # -> overrides @domainUpdated
    @domainSet = no
    @rangeSet = no

    # Whether the domain/range has been updated or if
    # still default values
    @domainUpdated = false
    @id = gg.Scale::_id += 1

    # center scale on this value -- only useful for continuous scales
    @center = null


    @parseSpec()

  parseSpec: ->
    @aes = @spec.aes
    unless @aes?
      throw Error("Scale.fromSpec needs an aesthetic: #{JSON.stringify @spec}")

    if @spec.range? and @aes not in gg.Scale.xys
      @range @spec.range
      @rangeSet = yes

    domain = findGoodAttr @spec, ['domain','limit','limits','lims','lim'], null
    if domain?
      @domain domain
      @domainSet = yes

    @center = findGood [@spec.center, null]

    # copy over other spec key-val pairs?
    # for key, val of spec
    #   @[key] = val

  ########
  #
  # Static class methods
  #
  ########

  @xs = ['x', 'x0', 'x1']
  @ys = ['y', 'y0', 'y1']
  @xys = @xs.concat @ys
  @legendAess = ['size', 'group', 'color']

  @klasses: ->
    klasses = [
      gg.IdentityScale,
      gg.LinearScale,
      gg.TimeScale,
      gg.LogScale,
      gg.CategoricalScale,
      gg.ColorScale,
      gg.ShapeScale,
    ]
    ret = {}
    for klass in klasses
       for alias in _.flatten [klass.aliases]
         ret[alias] = klass
    ret



  @fromSpec: (spec={}) ->
    type = spec.type
    klasses = gg.Scale.klasses()
    klass = klasses[type] or gg.LinearScale

    aesAttrs = ['aesthetics', 'aesthetic', 'aes', 'var']
    spec.aes = findGoodAttr spec,  aesAttrs, null
    s = new klass spec
    s


  @defaultFor: (aes) ->
    klass = {
          x: gg.LinearScale
          x0: gg.LinearScale
          x1: gg.LinearScale
          y: gg.LinearScale
          y0: gg.LinearScale
          y1: gg.LinearScale
          color: gg.ColorScale
          fill: gg.ColorScale
          stroke: gg.ColorScale
          "fill-opacity": gg.LinearScale
          size: gg.LinearScale
          text: gg.TextScale
          shape: gg.ShapeScale
      }[aes] or gg.IdentityScale
    s = new klass {aes: aes}
    s

  clone: ->
    spec = _.clone @spec
    spec.aes = @aes
    ret = gg.Scale.fromSpec @spec
    ret.d3Scale = @d3Scale.copy() if @d3Scale?
    ret


  defaultDomain: (col) ->
    @min = _.min col
    @max = _.max col

    if @center?
        extreme = Math.max @max-@center, Math.abs(@min-@center)
        interval = [@center - extreme, @center + extreme]
    else
        interval = [@min, @max]
    interval

   # @param domain is output of gg.scale.domain()
   # Assume domain is [min, max] interval
   # Alternative subclasses can override
   mergeDomain: (domain) ->
     md = @domain()
     unless @domainSet
       if @domainUpdated and md? and md.length is 2
         @domain [_.min([md[0], domain[0]]), _.max([md[1], domain[1]])]
       else
         @domain domain


  domain: (interval) ->
    if interval? and not @domainSet
      @domainUpdated = yes
      @d3Scale.domain interval
    @d3Scale.domain()

  range: (interval) ->
    if interval? and not @rangeSet
      @d3Scale.range interval
    @d3Scale.range()

  #
  # XXX: need method to apply transformation but not scale to range
  #

  d3: -> @d3Scale
  valid: (v) -> yes
  minDomain: -> @domain()[0]
  maxDomain: -> @domain()[1]
  minRange: -> @range()[0]
  maxRange: -> @range()[1]
  scale: (v) -> @d3Scale v
  invert: (v) -> @d3Scale.invert(v)
  toString: () ->
    "#{@aes}: \t#{@domain()}\t#{@range()}"


class gg.IdentityScale extends gg.Scale
  @aliases = "identity"
  constructor: () ->
    @d3Scale = d3.scale.linear()
    @type = 'identity'
    super

  scale: (v) -> v
  invert: (v) -> v



class gg.LinearScale extends gg.Scale
  @aliases = "linear"
  constructor: () ->
    @d3Scale = d3.scale.linear()
    @type = 'continuous'
    super


class gg.TimeScale extends gg.Scale
  @aliases = "time"
  constructor: () ->
      @d3Scale = d3.time.scale()
      @type = 'time'
      super

class gg.LogScale extends gg.Scale
  @aliases = "log"
  constructor: () ->
      @d3Scale = d3.scale.log()
      @type = 'continuous'
      super

  valid: (v) -> v > 0

  defaultDomain: (col) ->
    col = _.filter col, (v) -> v > 0
    if col.length is 0
      return [1, 10]

    @min = _.min col
    @max = _.max col

    if @center?
        extreme = Math.max @max-@center, Math.abs(@min-@center)
        interval = [@center - extreme, @center + extreme]
    else
        interval = [@min, @max]

    interval

  scale: (v) -> if v is 0 then -1 else @d3Scale(v)


class gg.CategoricalScale extends gg.Scale
  @aliases = "categorical"

  # subclasses are responsible for instantiating @d3Scale and @invertScale
  constructor: (@padding=.05) ->
      @type = 'ordinal'
      super

  @defaultDomain: (col) ->
      vals = _.uniq _.flatten(col)
      vals.sort (a,b)->a-b
      vals

  clone: ->
    ret = super
    ret.invertScale = @invertScale.copy()
    ret

  defaultDomain: (col) -> gg.CategoricalScale.defaultDomain col

  mergeDomain: (domain) ->
    newDomain = _.uniq(_.union domain, @domain())
    console.log "#{@constructor.name}-#{@type} merging #{newDomain}"
    @domain newDomain

  domain: (interval) ->
    if interval?
      @invertScale.range interval
    super

  range: (interval) ->
    if interval? and not @rangeSet
      @d3Scale.rangeBands interval, @padding
      @invertScale.domain @d3Scale.range()
    @d3Scale.range()

class gg.ShapeScale extends gg.CategoricalScale
  @aliases = "shape"

  constructor: (@padding=1) ->
      customTypes = ['star', 'ex']
      @symbolTypes = d3.svg.symbolTypes.concat customTypes
      @d3Scale = d3.scale.ordinal().range @symbolTypes
      @invertScale = d3.scale.ordinal().domain @d3Scale.range()
      @symbScale = d3.svg.symbol()
      @type = 'shape'
      super

  range: (interval) -> # not allowed
  scale: (v, data, args...) ->
    throw Error("shape scale not thought through yet")
    size = args[0] if args? and args.length
    type = @d3Scale v
    r = Math.sqrt(size / 5) / 2
    diag = Math.sqrt(2) * r
    switch type
      when 'ex'
          "M#{-diag},#{-diag}L#{diag},#{diag}" +
              "M#{diag},#{-diag}L#{-diag},#{diag}"
      when 'cross'
          "M#{-3*r},0H#{3*r}M0,#{3*r}V#{-3*r}"
      when 'star'
          tr = 3*r
          "M#{-tr},0H#{tr}M0,#{tr}V#{-tr}" +
              "M#{-tr},#{-tr}L#{tr},#{tr}" +
              "M#{tr},#{-tr}L#{-tr},#{tr}"
      else
          @symbScale.size(size).type(@d3Scale v)()





class gg.ColorScaleCont extends gg.Scale
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

class gg.ColorScale extends gg.CategoricalScale
  @aliases = "color"

  constructor: (@spec={}) ->
    super
    @d3Scale = d3.scale.category20()
    @invertScale = d3.scale.ordinal()
    @invertScale.domain(@d3Scale.range()).range(@d3Scale.domain())
    @type = "color"


  invert: (v) -> @invertScale v


class gg.ColorScaleFuck extends gg.Scale
  @aliases = "color"

  constructor: (@spec={}) ->
    super
    @isDiscrete = no
    @cScale = new gg.ColorScaleCont @spec
    @dScale = new gg.ColorScaleDisc @spec
    @type = 'color'



  isNumeric: (col) -> _.every _.compact(col), _.isNumber
  myScale: -> if @isDiscrete then @dScale else @cScale
  d3: -> @myScale().d3()
  invert: (v) -> @myScale().invert v
  scale: (v) -> @myScale().scale v
  domain: (v) -> @myScale().domain v
  range: (v) -> @myScale().range v
  minDomain: -> @myScale().minDomain()
  maxDomain: -> @myScale().maxDomain()
  minRange: -> @myScale().minRange()
  maxRange: -> @myScale().maxRange()


  clone: ->
    spec = _.clone @spec
    ret = new gg.ColorScale spec
    ret.isDiscrete = @isDiscrete
    ret.cScale = @cScale.clone()
    ret.dScale = @dScale.clone()
    ret


  mergeDomain: (interval) ->
    console.log "scale.mergeDomain #{@isNumeric interval}  #{interval.length}"
    uniqs = _.uniq _.compact interval
    @isDiscrete = not (@isNumeric(uniqs) and uniqs.length > 20)

    domain = @defaultDomain interval
    @myScale().mergeDomain domain
    @domain()

  defaultDomain: (col) -> @myScale().defaultDomain col




class gg.TextScale extends gg.Scale
  @aliases = "text"
  constructor: () ->
      @type = 'text'
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




