groups = (g, klass, data) ->
    g.selectAll("g.#{klass}")
        .data(data)
        .enter()
        .append('g')
        .attr('class', klass)

class Geometry
    constructor: (spec) ->
        @color = spec.color or 'black'
        @width = spec.width or 2


class PointGeometry extends gg.Geometry
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
            .attr('fill', attributeValue @layer, 'color', @color)
            .attr('r', attributeValue @layer, 'size', @size)

class AreaGeometry extends gg.Geometry
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

class LineGeometry extends gg.Geometry
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

class IntervalGeometry extends gg.Geometry
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
            .attr('width', () => @width)
            .attr('height', (d) => @layer.scaledMin('y') - scale(d, 'y'))
            .attr('fill', attributeValue @layer, 'color', @color)

class BoxPlotGeometry extends gg.Geometry
    constructor: (spec) ->
        super spec

    # TODO: lots more geoms
    #

class TextGeometry extends gg.Geometry
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



