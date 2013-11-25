#<< gg/util/util



#
# Scales define scaling and aesthetic mapping for an aesthetic:
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
  @ggpackage = 'gg.scale.Scale'
  @log = gg.util.Log.logger @ggpackage, "scale"
  @aliases = "scale"
  @id: -> gg.scale.Scale::_id += 1
  _id: 0

  @xs = ['x', 'x0', 'x1']
  @ys = ['y', 'y0', 'y1', 'q1', 'median', 'q3', 'lower', 'upper', 'min', 'max']
  @xys = _.union @xs, @ys
  @legendAess = ['size', 'group', 'color', 'fill', 'fill-opacity']


  constructor: (@spec={}) ->
    @aes = @spec.aes
    unless @aes?
      throw Error("Scale.fromSpec needs an aesthetic: #{JSON.stringify @spec}")

    @rangeSet = no
    @domainSet = no

    if @spec.range? 
      @range @spec.range
      @rangeSet = yes

    attrs = ['domain','limit','limits','lims','lim']
    domain = gg.parse.Parser.attr @spec, attrs, null
    if domain?
      @domain domain
      @domainSet = yes

    @domainUpdated = @spec.domainUpdated or false
    @rangeUpdated = @spec.rangeUpdated or false
    @center = @spec.center
    @frozen = @spec.frozen or no

    @log = gg.util.Log.logger @ggpackage, "Scale #{@aes}.#{@id} (#{@type},#{@constructor.name})"
    @id = gg.scale.Scale.id()



  ########
  #
  # Static class methods
  #
  ########


  @klasses: ->
    klasses = [
      gg.scale.Identity,
      gg.scale.Linear,
      gg.scale.Time,
      gg.scale.Log,
      gg.scale.Ordinal,
      gg.scale.Color,
      gg.scale.Shape,
      gg.scale.ColorCont
    ]
    ret = {}
    for klass in klasses
       for alias in _.flatten [klass.aliases]
         ret[alias] = klass
    ret

  @fromSpec: (spec={}) ->
    klasses = gg.scale.Scale.klasses()
    klass = klasses[spec.type] or gg.scale.Linear
    new klass spec


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
      if klass == gg.scale.Color
        unless type is data.Schema.ordinal
          klass = gg.scale.ColorCont
      else if klass == gg.scale.Linear
        if type is data.Schema.ordinal
          klass = gg.scale.Ordinal
        else if type is data.Schema.date
          klass = gg.scale.Time

    @log "Scale: defaultFor(#{aes}, #{type}) -> #{klass.name}"
    new klass {aes: aes, type: type}

  clone: ->
    return gg.scale.Scale.fromJSON @toJSON()

  toJSON: ->
    spec = _.clone @spec
    spec.aes = @aes
    spec.type = @type
    spec.domainUpdated = @domainUpdated
    spec.domainSet = @domainSet
    spec.rangeUpdated = @rangeUpdated
    spec.rangeSet = @rangeSet
    spec.center = @center
    spec.frozen = @frozen

    spec.ggpackage = @constructor.ggpackage
    spec.domain = _.clone @domain()
    spec.range = _.clone @range()

    return spec

  @fromJSON: (json) ->
    klass = _.ggklass json.ggpackage
    clone = new klass json
    if clone.d3Scale?
      clone.d3Scale.domain json.domain
      clone.d3Scale.range json.range
    else
      clone.domain json.domain
      clone.range json.range

    clone.type = json.type
    clone.domainUpdated = json.domainUpdated
    clone.domainSet = json.domainSet
    clone.rangeUpdated = json.rangeUpdated
    clone.rangeSet = json.rangeSet
    clone.center = json.center
    clone.frozen = json.frozen
    clone








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
    if interval?
      unless @domainSet
        @domainUpdated = yes
        @d3Scale.domain interval
    @d3Scale.domain()

  range: (interval) ->
    if interval? 
      unless @rangeSet
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
