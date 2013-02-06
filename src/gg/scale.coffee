# Convenience class that creates identical gg.Scales objects
# from a single spec
#
# Used to create layer, panel and facet level copies of gg.Scales
# when training the scales
class gg.ScaleFactory
    constructor: (@spec) ->
        @paneDefaults = {}      # aes -> scale object
        @layerDefaults = {}     # [layerid,aes] -> scale object

        @setup @spec

    setup: ->

        # load graphic defaults
        _.each @spec.scales, (s) =>
            scale = gg.Scale.fromSpec s
            @paneDefaults[scale.aesthetic] = scale

        # load layer defaults
        _.each @spec.layers, (lspec, idx) =>
            if lspec.scales?
                _.each lspec.scales, (s) =>
                    scale = gg.Scale.fromSpec s
                    key = [idx, scale.aesthetic]
                    @layerDefaults[key] = scale



    scale: (aes, layer=null) ->
        if layer? and [layer.id, aes] of @layerDefaults
            @layerDefaults[[layer.id, aes]].clone()
        else if aes of @paneDefaults
            @paneDefaults[aes].clone()
        else
            gg.Scale.defaultFor aes

    scales: (aesthetics, layer=null) ->
        scales = new gg.Scales @
        _.each aesthetics, (aes) =>
            scales.scale(@scale aes, layer)
        scales



#
#
# Manage a graphic/pane/layer's set of scales
# a Wrapper around {aes -> {type -> scale} } + utility functions
#
class gg.Scales
    constructor: (@factory) ->
        @scales = {}
        @spec = {}

    clone: () ->
        ret = new gg.Scales @factory
        ret.spec = @spec
        ret.merge @
        ret

    # overwriting
    keep: (aesthetics) ->
        _.each _.keys(@scales), (aes) =>
            if aes not in aesthetics
                delete @scales[aes]
        @

    exclude: (aesthetics) ->
        _.each aesthetics, (aes) =>
            if aes of @scales
                delete @scales[aes]
        @

    aesthetics: -> _.keys @scales


    ensureScales: (aess) ->
        _.each aess, (aes) =>
            @scale(gg.Scale.defaultFor aes) if ! @scale(aes)
        @


    contains: (aes, type=null) -> aes of @scales and (not type or type of @scales[aes])
    scale: (aesOrScale, type=null) ->
        if typeof aesOrScale is 'string'
            aes = aesOrScale
            @scales[aes] = {} if aes not of @scales

            if type is null
                vals = _.values @scales[aes]
                if vals? and vals.length > 0 then vals[0] else null
            else
                @scales[aes][type] = @factory.scale aes if type not of @scales[aes]
                @scales[aes][type]

        else if aesOrScale?
            scale = aesOrScale
            aes = scale.aesthetic
            @scales[aes] = {} if aes not of @scales
            @scales[aes][scale.type] = scale



    # @param scalesArr array of gg.Scales objects
    # @return a single gg.Scales object that merges the inputs
    @merge: (scalesArr) ->
        if scalesArr.length is 0
            return null
        ret = scalesArr[0].clone()
        _.each scalesArr, (scales) ->
            ret.merge scales
        ret

    # @param scales a gg.Scales object
    # merges domains of argument scales with self
    # updates in place
    merge: (scales, insert=true) ->
        _.each scales.aesthetics(), (aes) =>
            if aes is 'text'
                return

            _.each scales.scales[aes], (scale, type) =>
                if @contains aes, type
                    @scale(aes, type).mergeDomain scales.scale(aes, type).domain()
                else if insert
                    @scale(scales.scale aes, type)
        @


    # each layer will call trainScales once with its own data
    # multiple layers may use same aesthetics so need to cope with
    # overlaps
    train: (data, layer) ->
        _.each layer.aesthetics(), (aes) =>
            _.each _.values(@scales[aes]), (s) =>
                # XXX: Only supports one text layer!
                if aes is 'text'
                    s.prepare layer, data, aes
                else
                    s.mergeDomain s.defaultDomain layer, data, aes
                    if aes in ['x', 'y']
                        s.range layer.pane.rangeFor aes
        @

    setRanges: (pane) ->
        _.each pane.aesthetics(), (aes) =>
            _.each _.values(@scales[aes]), (s) =>
                if aes in ['x', 'y']
                    s.range pane.rangeFor aes
        @


    toString: ->
        arr = _.flatten _.map @scales, (map, aes) =>
            _.map map, (scale, type) =>
                d3Scale = scale.d3Scale
                _.flatten([aes, '->', type, d3Scale.domain(), d3Scale.range()]).join(' ')
        arr.join('\n')



class gg.Scale
    constructor: () ->
        @domainSet = false

    @xs = ['x']
    @ys = ['y', 'y0', 'y1']
    @xys = @xs.concat @ys
    @legendAess = ['size', 'group', 'color']

    @fromSpec: (spec) ->
        s = new {
            linear: gg.LinearScale,
            time: gg.TimeScale,
            log: gg.LogScale,
            categorical: gg.CategoricalScale,
            color: gg.ColorScale
        }[spec.type or 'linear']

        s.spec = spec
        for key, val of spec
            if key is 'range'
                s.range val
            else
                s[key] = val if val?
        s

    @defaultFor: (aes) ->
        s = new ({
            x: gg.LinearScale,
            y: gg.LinearScale,
            y0: gg.LinearScale,
            y1: gg.LinearScale,
            color: gg.ColorScale,
            fill: gg.ColorScale,
            size: gg.LinearScale,
            text: gg.TextScale
        }[aes] or gg.LinearScale)()
        s.aesthetic = aes
        s

    clone: ->
        ret = gg.Scale.fromSpec(@spec)
        ret.d3Scale = @d3Scale.copy()
        ret.min = @min
        ret.max = @max
        ret.center = @center
        ret.domainSet = @domainSet
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
         if @domainSet and mydomain? and mydomain.length is 2
             [minv, maxv] = mydomain
             @domain [_.min([minv, domain[0]]), _.max([maxv, domain[1]])]
         else
             @domain domain


    domain: (interval) ->
        if interval?
            @domainSet = true
            @d3Scale =  @d3Scale.domain interval
        @d3Scale.domain()
    range: (i) ->
        if i?
            @d3Scale = @d3Scale.range i
        @d3Scale.range()
    scale: (v) -> @d3Scale v

class gg.LinearScale extends gg.Scale
    constructor: () ->
        @d3Scale = d3.scale.linear()
        @type = 'continuous'

class gg.TimeScale extends gg.Scale
    constructor: () ->
        @d3Scale = d3.time.scale()
        @type = 'time'

class gg.LogScale extends gg.Scale
    constructor: () ->
        @d3Scale = d3.scale.log()
        @type = 'continuous'

class gg.CategoricalScale extends gg.Scale
    constructor: (@padding=1) ->
        @d3Scale = d3.scale.ordinal()
        @type = 'ordinal'
    defaultDomain: (layer, data, aes) ->
        val = (d) -> layer.dataValue d, aes
        vals = _.uniq _.map(_.flatten(data), val)
        vals.sort (a,b)->a-b
        vals
    mergeDomain: (domain) ->
        @domain _.uniq(_.union domain, @domain())
    range: (interval) -> @d3Scale = @d3Scale.rangeBands interval, @padding

class gg.ColorScale extends gg.CategoricalScale
    constructor: () ->
        @d3Scale = d3.scale.category20()
        @type = 'color'
    range: (interval) ->
        console.log ['updating color', interval]
        @d3Scale = @d3Scale.range(interval)


class gg.TextScale extends gg.Scale
    constructor: () ->
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




