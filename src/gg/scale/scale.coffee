#<< gg/util/util
#<< gg/data/schema



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
class gg.scale.Scale
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
    @rangeUpdated = false
    @id = gg.scale.Scale::_id += 1

    # center scale on this value -- only useful for continuous scales
    @center = null


    @parseSpec()

  parseSpec: ->
    @aes = @spec.aes
    unless @aes?
      throw Error("Scale.fromSpec needs an aesthetic: #{JSON.stringify @spec}")

    range = _.findGoodAttr @spec, ["range"], null
    if range? and @aes not in gg.scale.Scale.xys
      @range range
      @rangeSet = yes



    attrs = ['domain','limit','limits','lims','lim']
    domain = _.findGoodAttr @spec, attrs, null
    if domain?
      @domain domain
      @domainSet = yes

    @center = _.findGood [@spec.center, null]
    @domainUpdated = _.findGood [@spec.domainUpdated, false]
    @rangeUpdated = _.findGood [@spec.rangeUpdated, false]

    @log = gg.util.Log.logger "Scale #{@aes}.#{@id} (#{@type},#{@constructor.name})", gg.util.Log.WARN

    # copy over other spec key-val pairs?
    # for key, val of spec
    #   @[key] = val

  ########
  #
  # Static class methods
  #
  ########

  @xs = ['x', 'x0', 'x1']
  @ys = ['y', 'y0', 'y1', 'q1', 'median', 'q3', 'lower', 'upper', 'min', 'max']
  @xys = _.union @xs, @ys
  @legendAess = ['size', 'group', 'color', 'fill', 'fill-opacity']

  @klasses: ->
    klasses = [
      gg.scale.Identity,
      gg.scale.Linear,
      gg.scale.Time,
      gg.scale.Log,
      gg.scale.Ordinal,
      gg.scale.Color,
      gg.scale.Shape,
    ]
    ret = {}
    for klass in klasses
       for alias in _.flatten [klass.aliases]
         ret[alias] = klass
    ret



  @fromSpec: (spec={}) ->
    type = spec.type
    klasses = gg.scale.Scale.klasses()
    klass = klasses[type] or gg.scale.Linear

    aesAttrs = ['aesthetics', 'aesthetic', 'aes', 'var']
    spec.aes = _.findGoodAttr spec,  aesAttrs, null
    s = new klass spec
    s


  @defaultFor: (aes, type) ->
    klass = {
          x: gg.scale.Linear
          x0: gg.scale.Linear
          x1: gg.scale.Linear
          y: gg.scale.Linear
          y0: gg.scale.Linear
          y1: gg.scale.Linear
          color: gg.scale.Color
          fill: gg.scale.Color
          stroke: gg.scale.Color
          "fill-opacity": gg.scale.Linear
          "opacity": gg.scale.Linear
          "stroke-opacity": gg.scale.Linear
          size: gg.scale.Linear
          text: gg.scale.Text
          shape: gg.scale.Shape
      }[aes] or gg.scale.Identity

    if type?
      if klass.name == gg.scale.Color
        unless type is gg.data.Schema.ordinal
          klass = gg.scale.ColorCont
      else if klass == gg.scale.Linear
        if type is gg.data.Schema.ordinal
          klass = gg.scale.Ordinal

    gg.util.Log.log "Scale: defaultFor(#{aes}, #{type}) -> #{klass.name}"

    s = new klass {aes: aes, type: type}
    s

  clone: ->
    klass = @constructor
    spec = _.clone @spec
    spec.aes = @aes
    spec.type = @type
    spec.domainUpdated = @domainUpdated
    spec.domainSet = @domainSet
    spec.rangeUpdated = @rangeUpdated
    spec.rangeSet = @rangeSet
    spec.center = @center

    ret = new klass spec
    ret.d3Scale = @d3Scale.copy() if @d3Scale?
    ret


  defaultDomain: (col) ->
    @min = _.mmin col
    @max = _.mmax col

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
     if @domainUpdated and md? and md.length == 2
       if _.isNaN(domain[0]) or _.isNaN(domain[1])
         throw Error("domain is invalid: #{domain}")
       @domain [
         Math.min md[0], domain[0]
         Math.max md[1], domain[1]
       ]
     else
       @domain domain


  domain: (interval) ->
    if interval? and not @domainSet
      @domainUpdated = yes
      @d3Scale.domain interval
    @d3Scale.domain()

  range: (interval) ->
    if interval? and not @rangeSet
      @rangeUpdated = true
      @d3Scale.range interval
    @d3Scale.range()

  #
  # XXX: need method to apply transformation but not scale to range
  #

  d3: -> @d3Scale
  valid: (v) ->
    if @domainUpdated or @domainSet
      @minDomain() <= v and v <= @maxDomain()
    else
      v?
  minDomain: -> @domain()[0]
  maxDomain: -> @domain()[1]
  resetDomain: ->
    @domain([0,1])
    @domainUpdated = false
  minRange: -> @range()[0]
  maxRange: -> @range()[1]
  scale: (v) -> @d3Scale v
  invert: (v) -> @d3Scale.invert(v)
  toString: () -> "#{@aes}.#{@id} (#{@type},#{@constructor.name}): \t#{@domain()} -> #{@range()}"
