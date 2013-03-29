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

    domain = findGood [@spec.domain, @spec.lim, null]
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
    klass = klasses[type] or gg.IdentityScale

    spec.aes = findGood [
      spec.aesthetics,
      spec.aesthetic,
      spec.aes,
      spec.var,
      null]

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
          size: gg.LinearScale
          text: gg.TextScale
          shape: gg.ShapeScale
      }[aes] or gg.IdentityScale
    s = new klass {aes: aes}
    s

  clone: ->
    ret = gg.Scale.fromSpec @spec
    _.extend ret, _.pick(@, [
      'mergeDomain', 'domain', 'range',
      'scale', 'invert', 'aes'])
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

  valid: (v) -> yes

  domain: (interval) ->
    if interval? and not @domainSet
        @domainUpdated = yes
        @d3Scale =  @d3Scale.domain interval
    @d3Scale.domain()

  range: (interval) ->
    if interval? and not @rangeSet
      @d3Scale = @d3Scale.range interval
    @d3Scale.range()

  #
  # XXX: need method to apply transformation but not scale to range
  #

  scale: (v) -> @d3Scale v
  invert: (v) -> @d3Scale.invert(v)


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
      @d3Scale = d3.scale.linear().clamp(true)
      @type = 'continuous'
      super


class gg.TimeScale extends gg.Scale
  @aliases = "time"
  constructor: () ->
      @d3Scale = d3.time.scale().clamp(true)
      @type = 'time'
      super

class gg.LogScale extends gg.Scale
  @aliases = "log"
  constructor: () ->
      @d3Scale = d3.scale.log().clamp(true)
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

    console.log "logScale defaultdomain: #{interval}"
    interval

  scale: (v) ->
    console.log "scaling #{v} -> #{@d3Scale(v)}"
    if v is 0 then -1 else @d3Scale(v)


class gg.CategoricalScale extends gg.Scale
  @aliases = "categorical"
  constructor: (@padding=1) ->
      @d3Scale = d3.scale.ordinal()
      @type = 'ordinal'
      super

  @defaultDomain: (col) ->
      vals = _.uniq _.flatten(col)
      vals.sort (a,b)->a-b
      vals

  defaultDomain: (col) -> gg.CategoricalScale.defaultDomain col

  mergeDomain: (domain) -> @domain _.uniq(_.union domain, @domain())

  range: (interval) ->
    if interval? and not @rangeSet
      @d3Scale = @d3Scale.rangeBands interval, @padding
    @d3Scale.range()

class gg.ShapeScale extends gg.CategoricalScale
  @aliases = "shape"

  constructor: (@padding=1) ->
      customTypes = ['star', 'ex']
      @symbolTypes = d3.svg.symbolTypes.concat customTypes
      @d3Scale = d3.scale.ordinal().range @symbolTypes
      @symbScale = d3.svg.symbol()
      @type = 'shape'
      super

  range: (interval) -> # not allowed
  scale: (v, data, args...) ->
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






class gg.ColorScale extends gg.Scale
  @aliases = "color"

  constructor: (@spec={}) ->
      @d3Scale = d3.scale.linear().clamp(true) # default to linear scale
      @type = 'color'
      @startColor = @spec.startColor or d3.rgb 255, 247, 251
      @endColor = @spec.endColor or d3.rgb 2, 56, 88
      @fixedScale = d3.scale.linear().range [@startColor, @endColor]
      super


  isNumeric: (col) -> _.every _.compact(col), _.isNumber


  defaultDomain: (col) ->
      uniqueVals = gg.CategoricalScale.defaultDomain col

      if @isNumeric(col) and uniqueVals.length > 20
          @d3Scale = @fixedScale
          _.extend @, _.pick(gg.Scale.prototype,
              'mergeDomain', 'domain', 'range', 'scale', 'invert')
          @mergeDomain super(col)
      else
          @d3Scale = d3.scale.category20()
          @.range = (interval=null) =>
            @d3Scale = @d3Scale.range(interval) if interval?
            @d3Scale.range()
          _.extend @, _.pick(gg.CategoricalScale.prototype,
              'mergeDomain', 'domain', 'scale')
          @mergeDomain uniqueVals
          @invertScale = d3.scale.ordinal().domain(@d3Scale.range()).range(@d3Scale.domain())
          @.invert = (v) => @invertScale(v)



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




