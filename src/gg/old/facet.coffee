wrap_grid = () ->
    # estimate the optimal grid for the data

grid_grid = () ->
    1



# Everything is modeled as a Grid of Panels.
#
# WrapFacet and SingleFacet are special cases of the GridFacet
#
#
class gg.old.GridFacet
    constructor: (@graphic, spec) ->
        # x, y faceting groupby information
        @groupX = spec.x or (d) -> 'X'
        @groupY = spec.y or (d) -> 'Y'
        @groupX = ((row) -> row[spec.x]) if typeof spec.x is 'string'
        @groupY = ((row) -> row[spec.y]) if typeof spec.y is 'string'
        @type = spec.type or 'grid'
        @scales = spec.scales or 'fixed'
        @sizing = spec.sizing or 'fixed'
        @panes = []

        @xs = []
        @ys = []
        @xScales = []
        @yScales = []
        @subFacets = {}
        @facetKeys = []

        @margin = 10
        @labelSize = 20
        @labelPadding = 4
        @facetSize = @labelSize + @labelPadding *2


        # Display options
        # spacing between panels
        # panel border
        # xlabel, ylabel sizes
        # xlabel, ylabel text
        #


    # Sets @xs, @ys, @facetData
    splitData: (data) ->
        if typeof @groupX is "object"
            # every column contains the same dataset
            1
        if typeof @groupY is 'object'
            # every row contains same dataset
            1


        # TODO: potentially support datavore
        @xs = (_.uniq _.map data, @groupX).sort()
        @ys = (_.uniq _.map data, @groupY).sort()

        @facetData = {}  # stores each pane's data
        _.each @xs, (x) =>
            @facetData[x] = {}
            _.each @ys, (y) => @facetData[x][y] = []

        # split the dataset by panels
        _.each data, (row) =>
            @facetData[@groupX row][@groupY row].push row




    # Split data by facet group functions
    # Tell layers to prepare their own scales an ddata
    # Optimize scales, sizing from layers
    prepare: (data) ->
        @splitData data

        @subFacets = {}  # panes X,Y indexed
        @panes = []      # panes linear list
        @facetKeys = []  # list of [X,Y] for faster indexing

        _.each @xs, (x) =>
            @subFacets[x] = {}
            _.each @ys, (y) =>
                pane = new gg.Pane @, @graphic
                @subFacets[x][y] = pane
                @panes.push pane
                @facetKeys.push [x,y]


        # now set each pane's data
        _.each @facetKeys, ([x,y]) =>
            @subFacets[x][y].prepare @facetData[x][y]

        @trainScales()

    expandDomains: (scales) ->
        _.each gg.Scale.xys, (aes) =>
            if scales.contains aes
                d = scales.scale(aes).domain()
                range = d[1] - d[0]
                padding = 0.1 * range
                d = [d[0]-padding, d[1]+padding]
                scales.scale(aes).domain d

    trainScales: ->
        @masterScales = gg.Scales.merge(_.map @panes, (p) -> p.scales)
        @expandDomains(@masterScales)
        if @scales is 'fixed'
            _.each @panes, (p) => p.scales.merge @masterScales, false
        else
            @trainFreeScales()

    trainFreeScales: ->

        # now compute the shared scales for each column and row
        @xScales = _.map @xs, (x) =>
            gg.Scales.merge(_.map @ys, (y) => @subFacets[x][y].scales)
                .exclude(gg.Scale.ys)

        @yScales = _.map @ys, (y) =>
            gg.Scales.merge(_.map @xs, (x) => @subFacets[x][y].scales)
               .exclude(gg.Scale.xs)

        _.each _.union(@xScales, @yScales), @expandDomains

        # update panes' scales to match along columns and rows
        _.each @xs, (x, xIdx) =>
            _.each @ys, (y, yIdx) =>
                paneScales = @subFacets[x][y].scales
                paneScales.merge @xScales[xIdx], false
                paneScales.merge @yScales[yIdx], false


    renderFacetLabels: (xFacet, yFacet, svg) ->
        facetSize = @facetSize
        labelPadding = @labelPadding
        xBand = xFacet.rangeBand()
        yBand = yFacet.rangeBand()


        xLabels = svg.append('g').attr('transform', "translate(#{facetSize}, 0)")
            .selectAll("g").data(@xs)
        xEnter = xLabels.enter().insert('g').attr('class', 'facet-label x')
        xEnter.append('rect')
        xEnter.append('text')

        xLabels.select("text").text(String)
        xEnter.select('text')
            .attr("x", (d) -> xFacet(d) + xBand / 2)
            .attr('y', facetSize)
            .attr("dy", "0.2em")
        xEnter.select("rect")
            .attr("x", xFacet)
            .attr("width", xBand)
            .attr("y", 0)
            .attr("height", facetSize)

        yLabels = svg.append('g')
            .attr('transform', "translate(#{@width-facetSize}, #{facetSize})")
            .selectAll("g").data(@ys, String)
        yEnter = yLabels.enter().insert('g').attr('class', 'facet-label y')
        yEnter.append('rect')
        yEnter.append('text')

        yLabels.select("text").text(String)
        yEnter.select("text")
            .attr("y", (d) -> yFacet(d) + yBand / 2)
            .attr("x", "0.2em")
            .attr("rotate", 90)
        yEnter.select("rect")
            .attr("y", yFacet)
            .attr("height", yBand)
            .attr("x", 0)
            .attr("width", facetSize)



    render: (@width, @height, svg, data) ->
        #@prepare data

        # add margins
        margin = @margin / 2
        matrix = "#{1.0-2*margin/@width},0,0,
                  #{1.0-2*margin/@height},
                  #{margin}, #{margin}"
        svg = svg.append('g')
            .attr('transform', "matrix(#{matrix})")

        svg.append('rect')
            .attr('class', 'plot-background')
            .attr('x', 0)
            .attr('y', 0)
            .attr('width', @width)
            .attr('height', @height)


        facetWidth = @width - 2*@facetSize
        facetHeight = @height - 2*@facetSize
        xFacet = d3.scale.ordinal().domain(@xs).rangeBands([0, facetWidth], 0.05)
        yFacet = d3.scale.ordinal().domain(@ys).rangeBands([0, facetHeight], 0.05)
        xBand = xFacet.rangeBand()
        yBand = yFacet.rangeBand()


        @renderFacetLabels(xFacet, yFacet, svg)



        # Now create containers for each pane
        matrix = "1,0,0,1,#{@facetSize}, #{@facetSize}"
        facetContainer = svg.append('g')
            .attr("transform", "matrix(#{matrix})")
            .attr("class", "facet-grid-container")

        _.each @xs, (x, xidx) =>
            _.each @ys, (y, yidx) =>
                cell = facetContainer.append('g')
                    .attr('transform', "translate(#{xFacet(x)},#{yFacet(y)})")
                    .attr("id", "facet-grid-#{xidx}-#{yidx}")
                    .attr("class", "facet-row-#{xidx} facet-col-#{yidx} facet-grid")

                pane = @subFacets[x][y]
                xText = xidx is 0
                yText = yidx is @ys.length - 1
                pane.render xBand, yBand, xText, yText, cell

class gg.old.SingleFacet extends gg.GridFacet
    constructor: (@graphic, spec) ->
        super @graphic, spec

        @facetSize = 0
        @labelPadding = 0

    renderFacetLabels: (xFacet, yFacet, svg) ->


