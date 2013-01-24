class Scale
    constructor: () ->

    @fromSpec: (spec) ->
        s = new {
            linear: gg.LinearScale,
            time: gg.TimeScale,
            log: gg.LogScale,
            categorical: gg.CategoricalScale,
            color: gg.ColorScale
        }[spec.type or 'linear']

        for key, val of spec
            s[key] = val if val?
        s

    @defaultFor: (aes) ->
        s = new {
            x: gg.LinearScale,
            y: gg.LinearScale,
            y0: gg.LinearScale,
            y1: gg.LinearScale,
            color: gg.ColorScale,
            fill: gg.ColorScale,
            size: gg.LinearScale,
            text: gg.TextScale
        }[aes]()
        s.aesthetic = aes
        s

    defaultDomain: (layer, data, aes) ->
        @min = if @min? then @min else layer.graphic.dataMin data, aes
        @max = if @max? then @max else layer.graphic.dataMax data, aes
        @domainSet = true
        if @center?
            extreme = Math.max @max-@center, Math.abs(@min-@center)
            @domain [@center - extreme, @center + extreme]
        else
            @domain [@min, @max]

    domain: (interval) -> @d3Scale =  @d3Scale.domain interval
    range: (i) -> @d3Scale = @d3Scale.range i
    scale: (v) -> @d3Scale v

class LinearScale extends gg.Scale
    constructor: () ->
        @d3Scale = d3.scale.linear()

class TimeScale extends gg.Scale
    constructor: () ->
        @d3Scale = d3.time.scale()

class LogScale extends gg.Scale
    constructor: () ->
        @d3Scale = d3.scale.log()

class CategoricalScale extends gg.Scale
    constructor: () ->
        @d3Scale = d3.scale.ordinal()
        @padding = 1
    values: (vals) ->
        @domainSet = true
        @domain vals
    defaultDomain: (layer, data, aes) ->
        val = (d) -> layer.dataValue d, aes
        vals = _.uniq _.map(_.flatten(data), val)
        vals.sort (a,b)->a-b
        @values vals
    range: (interval) -> @d3Scale = @d3Scale.rangeBands interval, @padding

# TODO: ColorScale, TextScale
class ColorScale extends gg.CategoricalScale
    constructor: () ->
        @d3Scale = d3.scale.category20()

    range: (interval) -> @d3Scale = @d3Scale.range(interval)


class TextScale extends gg.Scale
    constructor: () ->

    prepare: (layer, newData, aes) ->
        @pattern = layer.mappings[aes]
        @data = newData

    scale: (v, data) ->
        format = (match, key) ->
            it = data[key]
            it = it.toFixed 2 if (typeof it is 'number')
            String it
        @pattern.replace /{(.*?)}/g, format




