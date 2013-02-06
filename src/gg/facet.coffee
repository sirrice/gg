wrap_grid = () ->
    # estimate the optimal grid for the data

grid_grid = () ->
    1



# Everything is modeled as a Grid of Panels.
#
# WrapFacet and SingleFacet are special cases of the GridFacet
#
#
class gg.GridFacet
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
        @subFacets = {}
        @facetKeys = []
        @colScales = null
        @rowScales = null

        @margin = 10


        # Display options
        # spacing between panels
        # panel border
        # xlabel, ylabel sizes
        # xlabel, ylabel text
        #



    # Split data by facet group functions
    # Tell layers to prepare their own scales an ddata
    # Optimize scales, sizing from layers
    prepare: (data) ->
        group = (row) => [@groupX(row), @groupY(row)]
        @xs = (_.uniq _.map data, @groupX).sort()
        @ys = (_.uniq _.map data, @groupY).sort()

        # create grid[x][y] and populate with
        @facetData = {}  # stores each pane's data
        @subFacets = {}  # panes X,Y indexed
        @panes = []      # panes linear list
        @facetKeys = []  # list of [X,Y] for faster indexing
        _.each @xs, (x) =>
            @facetData[x] = {}
            @subFacets[x] = {}
            _.each @ys, (y) =>
                pane = new gg.Pane @, @graphic
                @facetData[x][y] = []
                @subFacets[x][y] = pane
                @panes.push pane
                @facetKeys.push [x,y]


        # split the dataset by panels
        _.each data, (row) =>
            @facetData[@groupX row][@groupY row].push row

        # now set each pane's data
        _.each @facetKeys, (key) =>
            [x,y] = key
            @subFacets[x][y].prepare @facetData[x][y]

        if @scales is 'fixed'
            @trainFixedScales()
        else
            @trainFreeScales()


    trainFixedScales: ->
        # TODO: move xAesthetics/yAesthetics/aesthetics into one place
        aesthetics = ['x', 'y', 'y0', 'y1']
        masterScales = gg.Scales.merge(_.map @panes, (p) -> p.scales)
        console.log String(masterScales)
        masterScales = masterScales.keep(aesthetics)
        console.log String(masterScales)

        _.each @panes, (p) =>
            p.scales.merge masterScales, false


    trainFreeScales: ->

        # now compute the shared scales for each column and row
        xAesthetics = ['x']
        colScales = _.map @xs, (x) =>
            gg.Scales.merge(_.map @ys, (y) => @subFacets[x][y].scales)
                .keep(xAesthetics)
        @xScales = colScales

        yAesthetics = ['y', 'y0', 'y1']
        rowScales = _.map @ys, (y) =>
            gg.Scales.merge(_.map @xs, (x) => @subFacets[x][y].scales)
               .keep(yAesthetics)
        @yScales = rowScales

        # update panes' scales to match along columns and rows
        _.each @xs, (x, xIdx) =>
            _.each @ys, (y, yIdx) =>
                paneScales = @subFacets[x][y].scales
                paneScales.merge colScales[xIdx], false
                paneScales.merge rowScales[yIdx], false


    renderFacetLabels: (facetSize, labelPadding, xFacet, yFacet, svg) ->
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
            .attr("y", labelPadding + facetSize/2)
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
            .attr("x", labelPadding)
            .attr("rotate", 90)
        yEnter.select("rect")
            .attr("y", yFacet)
            .attr("height", yBand)
            .attr("x", 0)
            .attr("width", facetSize)



    render: (@width, @height, svg, data) ->
        # compute layout of the facets
        # decide if x/y labels need to be rendered
        # create the containers

        @prepare data
        # each pane's layers has trained their scales

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

        # TODO: make this configurable
        labelSize = 20
        labelPadding = 4
        facetSize = labelSize + labelPadding*2

        facetWidth = @width - 2*facetSize
        facetHeight = @height - 2*facetSize
        xFacet = d3.scale.ordinal().domain(@xs).rangeBands([0, facetWidth], 0.05)
        yFacet = d3.scale.ordinal().domain(@ys).rangeBands([0, facetHeight], 0.05)
        xBand = xFacet.rangeBand()
        yBand = yFacet.rangeBand()


        @renderFacetLabels(facetSize, labelPadding, xFacet, yFacet, svg)



        # Now create containers for each pane
        matrix = "1,0,0,1,#{facetSize}, #{facetSize}"
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
                pane.render xBand, yBand, cell
                pane.renderXAxis cell, yidx is @ys.length-1
                pane.renderYAxis cell, xidx is 0


class gg.SingleFacet extends gg.GridFacet
    constructor: (@graphic, spec) ->
        super @graphic, spec


