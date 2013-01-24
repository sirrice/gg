class GridFacet
    constructor: (spec) ->
        # x, y faceting groupby information
        @groupX = spec.groupX or (d) -> 'X'
        @groupY = spec.groupY or (d) -> 'Y'
        @subFacets = null

    prepare: (data) ->
        group = (data) => [@groupX(data), @groupY(data)]

        # group the data by x,y

    render: (w, h, svg, data) ->
        # compute layout of the facets
        _.each @subFacets,




class SingleFacet
    constructor: (@graphic) ->

    render: (@weight, @height, svg, data) ->

        svg.append('rect')
            .attr('class', 'base')
            .attr('fill', 'white')
            .attr('x', 0)
            .attr('y', 0)
            .attr('width', @width)
            .attr('height', @height)

        @graphic.ensureScales()
        @graphic.prepareLayers data


        # Draws Axes then calls layer renderers with non-axis space

        # Create d3 axis objects
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
            .attr('fill', 'none')
            .attr('transform', "translate(0, #{@height-@graphic.paddingY})")
            .call(xAxis)

        svg.append('g')
            .attr('class', 'y axis')
            .attr('transform', "translate(#{@graphic.paddingX}, 0)")
            .call(yAxis)

        svg.append('g')
            .attr('class', 'x legend')
            .attr('transform', "translate(#{@width/2}, #{@height-5})")
            .append('text')
            .text(@graphic.legend('x'))
            .attr('text-anchor', 'middle')

        svg.append('g')
            .attr('class', 'y legend')
            .attr('transform', "translate(10, #{@height/2}) rotate(-90)")
            .append('text')
            .text(@graphic.legend('y'))
            .attr('text-anchor', 'middle')


        # each layer draws their contents
        _.each @graphic.layers, (layer) => layer.render @graphic.svg.append('g')


