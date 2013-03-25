groups = (g, klass, data) ->
    g.selectAll("g.#{klass}")
        .data(data)
        .enter()
        .append('g')
        .attr('class', "#{klass}")

class gg.old.Geometry
    constructor: (spec) ->
        @color = spec.color or 'black'
        @width = spec.width or 2
        @layer = null


class gg.old.PointGeometry extends gg.Geometry
    constructor: (spec) ->
        @size = spec.size or 5
        @shape = spec.shape or 'circle'
        super spec

    render: (g, data) ->
        addCoord = (ds) =>
            _.each ds, (d) =>
                x = @layer.scaledValue d, 'x'
                y = @layer.scaledValue d, 'y'
                r = attributeValue(@layer, 'size', @size)(d)/2
                f = attributeValue(@layer, 'color', @color)(d)
                d['__x__'] = x
                d['__y__'] = y
                d['__r__'] = r
                d['__f__'] = f
                d
            ds

        if 'shape' not of @layer.mappings or @layer.mappings['shape'] is 'circle'
            groups(g, 'circles geoms', data).selectAll('circle')
                .data(addCoord)
                .enter()
                .append('circle')
                .attr('class', 'geom')
                .attr('cx', (d) => d['__x__'])
                .attr('cy', (d) => d['__y__'])
                .attr('fill-opacity', @alpha)
                .attr('fill', (d) => d['__f__'])
                .attr('r', (d) => d['__r__'])
        else
            val = (d, aes) => @layer.scaledValue d, aes
            xformfunc = (d) -> "translate(#{val d, 'x'},#{val d, 'y'})"
            shapef = (d) =>
                size = attrVal(@layer, 'size', @size)(d)
                attrVal(@layer, 'shape', @shape, size)(d)
            groups(g, 'symbols geoms', data).selectAll('path')
                .data(addCoord)
                .enter()
                .append('path')
                .attr('class', 'geom')
                .attr('transform', xformfunc)
                .attr('fill-opacity', @alpha)
                .attr('fill', attributeValue @layer, 'color', @color)
                .attr('stroke', attributeValue @layer, 'color', @color)
                .attr('stroke-width', 1)
                .attr('d', shapef)

        g.selectAll('.geom')
            .on('mouseover', (ev) =>)


class gg.old.AreaGeometry extends gg.Geometry
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

class gg.old.LineGeometry extends gg.Geometry
    constructor: (spec) ->
        super spec

    render: (g, data) ->
        scale = (d, aes) => @layer.scaledValue d, aes
        if 'color' of @layer.mappings
            color = (d) -> scale d[0], 'color'
        else
            color = @color

        line = d3.svg.line()
            .x((d,i) -> scale d, 'x')
            .y((d,i) -> scale d, 'y')
            .interpolate('linear')

        groups(g, 'lines', data).selectAll('path')
            .data((d) -> [d]).enter().append('path')
            .attr('d',  line)
            .attr('fill', 'none')
            .attr('stroke-width', @width)
            .attr('stroke', color)

class gg.old.IntervalGeometry extends gg.Geometry
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
            .attr('width', attributeValue @layer, 'width', @width)#() => @width)
            .attr('height', (d) => @layer.scaledMin('y') - scale(d, 'y'))
            .attr('fill', attributeValue @layer, 'color', @color)

class gg.old.BoxPlotGeometry extends gg.Geometry
    constructor: (spec) ->
        super spec

    # TODO: lots more geoms
    #

class gg.old.TextGeometry extends gg.Geometry
    constructor: (spec) ->
        @show = spec.show
        @offsetX = spec.offsetX or 5
        @offsetY = spec.offsetY or -10
        super spec

    render: (g, data) ->
        area = g.append 'g'
        text = groups(area, 'text', data).selectAll('circle')
            .data((d,i)-> d)
            .enter()
            .append('text')
            .attr('class', 'graphicText')
            .attr('x', (d) => @offsetX + @layer.scaledValue d, 'x')
            .attr('y', (d) => @offsetY + @layer.scaledValue d, 'y')
            .text((d) => @layer.scaledValue d, 'text')

        text.attr('class', 'graphicText showOnHover') if @show is 'hover'
        @



