# @param undef undefined variable
_myfunc = (exports,undef) ->

    _ = exports._
    d3 = exports.d3

    if !_ and !d3 and require?
        d3 = require 'd3'
        _ = require 'underscore'

    class Graphic
        constructor: (@opts) ->
            @layers = []
            @scales = {}

            @opts = @opts or { padding: 35 }
            # TODO: move this into addtl parameters object!
            @paddingX = @opts.paddingX or @opts.padding
            @paddingY = @opts.paddingY or @opts.padding

        @fromSpec: (spec, opts) ->
            g = new Graphic opts
            _.each spec.layers, (s) -> g.layer(Layer.fromSpec s, g)
            _.each spec.scales, (s) -> g.scale(Scale.fromSpec s)
            g.facets = Facets.fromSpec spec.facets, g
            g

        rangeFor: (aes) ->
            if aes is 'x'
                [@paddingX, @width - @paddingX]
            else if aes is 'y'
                [@height - @paddingY, @paddingY]
            else
                throw "Only 2d graphics supported.  Unknown aes: #{aes}"

        ensureScales: () ->
            aess = _.union(_.flatten(_.invoke(@layers, 'aesthetics')))
            _.each aess, (aes) =>
                if ! @scales[aes]
                    @scales[aes] = Scale.defaultFor aes

        prepareLayers: (data) ->
            _.each @layers, (e) -> e.prepare data

        dataMin: (data, aes) ->
            layers = @layersWithAesthetic(aes)
            key = (layer) -> layer.dataMin(data, aes)
            key(_.min layers, key)

        dataMax: (data, aes) ->
            layers = @layersWithAesthetic(aes)
            key = (layer) -> layer.dataMax(data, aes)
            key(_.max layers, key)

        layersWithAesthetic: (aes) ->
            _.filter @layers, (layer) -> aes of layer.mappings

        render: (w, h, where, data) ->
            [@width, @height] = [w, h]
            @svg = where.append('svg')
                .attr('width', @width)
                .attr('height', @height)
            @facets.render w, h, @svg, data

        renderer: (w, h, where) ->
            (data) => @render w, h, where, data


        layer: (e) -> @layers.push e

        scale: (s) -> @scales[s.aesthetic] = s

        legend: (aes) -> @scales[aes].legend or @layers[0].legend aes

    Facets = {}

    Facets.fromSpec = (spec, graphic) ->
        if spec?
            throw 'Other facets not implemented'
        else
            new SingleFacet graphic

    class SingleFacet
        constructor: (@graphic) ->

        render: (w, h, svg, data) ->
            [@width, @height] = [w,h]

            svg.append('rect')
                .attr('class', 'base')
                .attr('x', 0)
                .attr('y', 0)
                .attr('width', @width)
                .attr('height', @height)

            @graphic.ensureScales()
            @graphic.prepareLayers data


            # Draws Axes then calls layer renderers with non-axis space
            xAxis = d3.svg.axis()
                .scale(@graphic.scales['x'].d3Scale)
                .tickSize(2*@graphic.paddingY - @height)
                .orient('bottom')

            yAxis = d3.svg.axis()
                .scale(@graphic.scales['y'].d3Scale)
                .tickSize(2*@graphic.paddingX - @width)
                .orient('left')

            # create the div for the x axis
            svg.append('g')
                .attr('class', 'x axis')
                .attr('transform', 'translate(0, #{@height-@graphic.paddingY})')
                .call(xAxis)

            svg.append('g')
                .attr('class', 'y axis')
                .attr('transform', 'translate(#{@graphic.paddingX}, 0)')
                .call(yAxis)

            svg.append('g')
                .attr('class', 'x legend')
                .attr('transform', 'translate(#{@width/2}, #{@height-5})')
                .append('text')
                .text(@graphic.legend('x'))
                .attr('text-anchor', 'middle')

            svg.append('g')
                .attr('class', 'y legend')
                .attr('transform', 'translate(10, #{@height/2}) rotate(270)')
                .append('text')
                .text(@graphic.legend('y'))
                .attr('text-anchor', 'middle')


            # each layer draws their contents
            _.each @graphic.layers, (layer) => layer.render @graphic.svg.append('g')



    class Layer
        constructor: (@geometry, @graphic) ->
            @mappings = {}
            @statistic = null
            # also want positioner, data
            # where is aethetic here?

        @fromSpec: (spec, graphic) ->
            geom = new {
                point:    PointGeometry,
                line:     LineGeometry,
                area:     AreaGeometry,
                interval: IntervalGeometry,
                box:      BoxPlotGeometry,
                text:     TextGeometry
            }[spec.geometry || 'point'](spec);

            geom.layer = layer = new Layer geom, graphic
            layer.mappings = spec.mapping if spec.mapping?
            layer.statistic = Statistics.fromSpec spec.statistic or {kind: 'identity'}
            layer

        scaleExtracted: (v, aes, d) -> @graphic.scales[aes].scale v, d

        scaledValue: (d, aes) -> @scaleExtracted @dataValue(d, aes), aes, d

        scaledMin: (aes) ->
            s = @graphic.scales[aes]
            s.scale s.min

        aesthetics: () -> _.without _.keys(@mappings), 'group'

        trainScales: (newData) ->
            _.each @aesthetics(), (aes) =>
                s = @graphic.scales[aes]

                # TODO: domains of diff layers could be different!  Need to
                # normalize the domains
                if aes is 'text'
                    s.prepare @, newData, aes
                else
                    if !s.domainSet
                        s.defaultDomain @, newData, aes
                    if aes in ['x', 'y']
                        s.range @graphic.rangeFor(aes)

        prepare: (data) ->
            @newData = @statistic.compute data, @mappings
            @newData = _.values groupData(@newData, @mappings.group)
            @trainScales @newData

        render: (g) -> @geometry.render g, @newData


        dataValue: (datum, aes) -> datum[@mappings[aes]]


        dataMin: (data, aes) ->
            if @mappings[aes]
                key = (d) => @dataValue d, aes
                min = (d) -> _.min d, key
                key min(_.map(data, min))
            else
                (@statistic.dataRange data)[0]

        dataMax: (data, aes) ->
            if @mappings[aes]
                key = (d) => @dataValue d, aes
                max = (d) -> _.max d, key
                key max(_.map(data, max))
            else
                (@statistic.dataRange data)[1]

        legend: (aes) ->
            @mappings[aes] or @statistic.variable

    attributeValue = (layer, aes, defaultVal) ->
        if aes of layer.mappings then (d) -> layer.scaledValue d, aes else defaultValue

    class Geometry
        constructor: (spec) ->
            @color = spec.color or 'black'
            @width = spec.width or 2


    class PointGeometry extends Geometry
        constructor: (spec) ->
            @size = spec.size or 5
            super spec

        render: (g, data) ->
            groups(g, 'circles', data).selectAll('circle')
                .data(Object)
                .enter()
                .append('circle')
                .attr('cx', (d) => @layer.scaledValue d, 'x')
                .attr('cy', (d) => @layer.scaledValue d, 'y')
                .attr('fill-opacity', @alpha)
                .attr('fill', attributeValue layer, 'color', @color)
                .attr('r', attributeValue layer, 'size', @size)

    class AreaGeometry extends Geometry
        constructor: (spec) ->
            @fill = spec.fill or 'black'
            @alpha = spec.alpha or 1
            @stroke = spec.stroke or @fill
            super spec

        render: (g, data) ->
            scale = (d, key, aes) => @layer.scaleExtracted d[key], aes, d

            area = d3.svg.area()
                .x((d) -> scale d, 'x', 'x')
                .y1((d) -> scale d, 'y1', 'y')
                .y0((d) -> scale d, 'y0', 'y')
                .interpolate('basis')

            # attributes should be imported in bulk using
            # .attr( {} ) where {} is @attrs
            groups(g, 'lines', data).selectAll('polyline')
                .data((d) -> [d])
                .enter()
                .append('svg:path')
                .attr('d', area)
                .attr('stroke-width', @width)
                .attr('stroke', @stroke)
                .attr('fill', @fill)
                .attr('fill-opacity', @alpha)
                .attr('stroke-opacity', @alpha)

    class LineGeometry extends Geometry
        constructor: (spec) ->
            super spec

        render: (g, data) ->
            scale = (d, aes) => @layer.scaledValue d, aes
            color = if 'color' of @layer.mappings then (d) -> scale d[0], 'color' else @color
            line = d3.svg.line()
                .x((d) -> scale d, 'x')
                .y((d) -> scale d, 'y')
                .interpolate('linear')

            groups(g, 'lines', data).selectAll('polyline')
                .data((d) -> [d])
                .enter()
                .append('svg:path')
                .attr('d', line)
                .attr('fill', 'none')
                .attr('stroke-width', @width)
                .attr('stroke', color)

    class IntervalGeometry extends Geometry
        constructor: (spec) ->
            super spec

        render: (g, data) ->
            scale = (d, aes) => @layer.scaledValue d, aes
            groups(g, 'rects', data).selectAll('rect')
                .data(Object) # add a single element
                .enter()
                .append('rect')
                .attr('x', (d) => scale(d, 'x') - @width/2)
                .attr('y', (d) => scale(d, 'y'))
                .attr('width', @width)
                .attr('height', (d) => @layer.scaledMin('y') - scale(d, 'y'))
                .attr('fill', attributeValue layer, 'color', @color)

    class BoxPlotGeometry extends Geometry
        constructor: (spec) ->
            super spec

        # TODO: lots more geoms
        #

    class TextGeometry extends Geometry
        constructor: (spec) ->
            @show = spec.show
            super spec

        render: (g, data) ->
            area = g.append 'g'
            text = groups(area, 'text', data).selectAll('circle')
                .data(Object)
                .enter()
                .append('text')
                .attr('class', 'graphicText')
                .attr('x', (d) => @layer.scaledValue d, 'x')
                .attr('y', (d) => @layer.scaledValue d, 'y')
                .text((d) => @layer.scaledValue d, 'text')

            text.attr('class', 'graphicText showOnHover') if @show is 'hover'
            @




    groups = (g, klass, data) ->
        g.selectAll('g.#{klass}')
            .data(data)
            .enter()
            .append('g')
            .attr('class', klass)

    #
    ##
    #
    #
    #

    class Scale
        constructor: () ->

        @fromSpec: (spec) ->
            s = new {
                linear: LinearScale,
                time: TimeScale,
                log: LogScale,
                categorical: CategoricalScale,
                color: ColorScale
            }[spec.type or 'linear']

            for key, val of spec
                s[key] = val if val?
            s

        @defaultFor: (aes) ->
            s = new {
                x: LinearScale,
                y: LinearScale,
                y0: LinearScale,
                y1: LinearScale,
                color: ColorScale,
                fill: ColorScale,
                size: LinearScale,
                text: TextScale
            }[aes]()
            s.aesthetic = aes
            s

        defaultDomain: (layer, data, aes) ->
            @min = layer.graphic.datamin data, aes if not @min?
            @max = layer.graphic.dataMax data, aes if not @max?
            @domainSet = true
            if @center?
                extreme = Math.max @max-@center, Math.abs(@min-@center)
                @domain [@center - extreme, @center + extreme]
            else
                @domain [@min, @max]

        domain: (interval) -> @d3Scale =  @d3Scale.domain interval
        range: (i) -> @d3Scale = @d3Scale.range i
        scale: (v) -> @d3Scale v

    class LinearScale extends Scale
        constructor: () ->
            @d3Scale = d3.scale.linear()

    class TimeScale extends Scale
        constructor: () ->
            @d3Scale = d3.time.scale()

    class LogScale extends Scale
        constructor: () ->
            @d3Scale = d3.scale.llog()

    class CategoricalScale extends Scale
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
    class ColorScale extends CategoricalScale
        constructor: () ->
            @d3Scale = d3.scale.category20()

        range: (interval) -> @d3Scale = @d3Scale.range(interval)


    class TextScale extends Scale
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




    class Statistics
        @fromSpec: (spec) ->
            new {
                identity: IdentityStatistic,
                bin: BinStatistic,
                box: BoxPlotStatistic,
                sum: SumStatistic,
            }[spec.kind](spec)

    class Statistic
        constructor: (spec) ->
            @group = spec.group or false
            @variable = spec.variable # why just a single variable?


    class BinStatistic extends Statistic
        constructor: (spec) ->
            @bins = spec.bins or 20
            super spec

        compute: (data) ->
            vals = _.pluck data @variable
            histogram = d3.layout.histogram().bins(@bins)
            freq = histogram vals
            histogram.frequency false
            density = histogram vals
            _map frequency, (bin, i) =>
                bin: i, count: bin.y, density: density[i].y, ncount: bin.y / data.length or 0

    class SumStatistic extends Statistic
        constructor: (spec) ->
            super spec

        compute: (data) ->
            groups = groupData data @group
            value = _.bind (point) => point[@variable]
            _.map groups, (values, name) =>
                {
                    group : name,
                    count: values.length,
                    sum: d3.sum(values, value),
                    min: d3.min(values, value),
                    max: d3.max(values, value)
                }

    class BoxPlotStatistic extends Statistic
        constructor: (spec) ->
            super spec

        # @return [min, max]
        dataRange: (data) ->
            flattened = _.flatten data
            [
                _.min(_.pluck flattened, 'min'),
                _.max(_.pluck flattened, 'max')
            ]

        compute: (data) ->
            groups = groupData data @group

    class IdentityStatistic extends Statistic
        constructor: (spec) ->
            super spec

        compute: (data) ->
            data







    groupData = (data, groupBy) ->
        if not groupBy? then [data] else _.groupBy data, groupBy
    splitByGroups = (data, group, variable) ->
        groups = {}
        if group
            _.each data, (d) =>
                g = d[group]
                groups[g] = [] if not groups[g]?
                groups[g].push d[variable]
        else
            groups['data'] = _.pluck data, variable
        groups


    exports.gg = (spec, opts) -> return Graphic.fromSpec spec, opts





_myfunc(this)
