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
class gg.Scale
    constructor: () ->
        # Whether or not the domain/range was set from the Spec
        # -> don't update at all
        # -> overrides @domainUpdated
        @domainSet = false
        @rangeSet = false

        # Whether the domain/range has been updated or if
        # still default values
        @domainUpdated = false


    @xs = ['x', 'x0', 'x1']
    @ys = ['y', 'y0', 'y1']
    @xys = @xs.concat @ys
    @legendAess = ['size', 'group', 'color']

    @fromSpec: (spec) ->
      klasses =
        linear: gg.LinearScale
        time: gg.TimeScale
        log: gg.LogScale
        categorical: gg.CategoricalScale
        color: gg.ColorScale
        shape: gg.ShapeScale
      s = new klasses[spec? and spec.type or 'linear']

      s.spec = spec
      if spec?
        aes = findGood [spec.aesthetic, spec.aes, spec.var]
        s.aesthetic = aes
        for key, val of spec
          switch key
            when 'range'
              if aes not in ['x', 'y']
                s.range val
                s.rangeSet = true
            when 'domain', 'lim'
              s.domain val
              s.domainSet = true
            else
              s[key] = val if val?
      s

    @defaultFor: (aes) ->
        s = new ({
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
        }[aes] or gg.LinearScale)()
        s.aesthetic = aes
        s

    clone: ->
        ret = gg.Scale.fromSpec(@spec)
        _.extend ret, @
        ret.d3Scale = @d3Scale.copy()
        ret


    defaultDomain: (layer, data, aes) ->
        @min = if @min? then @min else layer.pane.dataMin data, aes
        @max = if @max? then @max else layer.pane.dataMax data, aes
        interval = []
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
         mydomain = @domain()
         if not @domainSet
             if @domainUpdated and mydomain? and mydomain.length is 2
                 [minv, maxv] = mydomain
                 @domain [_.min([minv, domain[0]]), _.max([maxv, domain[1]])]
             else
                 @domain domain


    domain: (interval) ->
        if interval? and not @domainSet
            @domainUpdated
            @d3Scale =  @d3Scale.domain interval
        @d3Scale.domain()
    range: (i) ->
        if i? and not @rangeSet
            @d3Scale = @d3Scale.range i
        @d3Scale.range()
    scale: (v) -> @d3Scale v

class gg.LinearScale extends gg.Scale
    constructor: () ->
        super
        @d3Scale = d3.scale.linear().clamp(true)
        @type = 'continuous'


class gg.TimeScale extends gg.Scale
    constructor: () ->
        super
        @d3Scale = d3.time.scale().clamp(true)
        @type = 'time'

class gg.LogScale extends gg.Scale
    constructor: () ->
        super
        @d3Scale = d3.scale.log().clamp(true)
        @type = 'continuous'


class gg.CategoricalScale extends gg.Scale
    constructor: (@padding=1) ->
        super
        @d3Scale = d3.scale.ordinal()
        @type = 'ordinal'

    @defaultDomain: (layer, data, aes) ->
        val = (d) -> layer.dataValue d, aes
        vals = _.uniq _.map(_.flatten(data), val)
        vals.sort (a,b)->a-b
        vals
    defaultDomain: (layer, data, aes) ->
        gg.CategoricalScale.defaultDomain layer, data, aes
    mergeDomain: (domain) ->
        @domain _.uniq(_.union domain, @domain())
    range: (interval) ->
        if not @rangeSet
            @d3Scale = @d3Scale.rangeBands interval, @padding

class gg.ShapeScale extends gg.CategoricalScale
    constructor: (@padding=1) ->
        super
        customTypes = ['star', 'ex']
        @symbolTypes = d3.svg.symbolTypes.concat customTypes
        @d3Scale = d3.scale.ordinal().range @symbolTypes
        @symbScale = d3.svg.symbol()
        @type = 'shape'
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
    constructor: (@spec={}) ->
        super
        @d3Scale = d3.scale.linear().clamp(true) # default to linear scale
        @type = 'color'
        @startColor = @spec.startColor or d3.rgb 255, 247, 251
        @endColor = @spec.endColor or d3.rgb 2, 56, 88
        @fixedScale = d3.scale.linear().range [@startColor, @endColor]

    isNumeric: (layer, data, aes) ->
        val = (d) -> layer.dataValue d, aes
        isNum = true
        for dataArr in data
            for d in dataArr
                if typeof val(d) is not 'number'
                    isNum = false
                    return isNum
        true


    defaultDomain: (layer, data, aes) ->
        val = (d) -> layer.dataValue d, aes
        uniqueVals = gg.CategoricalScale.defaultDomain(layer,data, aes)

        if @isNumeric(layer, data, aes) and uniqueVals.length > 20
            @d3Scale = @fixedScale
            _.extend @, _.pick(gg.Scale.prototype,
                'mergeDomain', 'domain', 'range', 'scale')
            @mergeDomain super(layer, data, aes)
        else
            @d3Scale = d3.scale.category20()
            @.range = (interval) -> @d3Scale = @d3Scale.range(interval)
            _.extend @, _.pick(gg.CategoricalScale.prototype,
                'mergeDomain', 'domain', 'scale')
            @mergeDomain uniqueVals


class gg.TextScale extends gg.Scale
    constructor: () ->
        super
        @type = 'text'

    prepare: (layer, newData, aes) ->
        @pattern = layer.mappings[aes]
        @data = newData

    scale: (v, data) ->
        format = (match, key) ->
            it = data[key]
            it = it.toFixed 2 if (typeof it is 'number')
            String it
        @pattern.replace /{(.*?)}/g, format




