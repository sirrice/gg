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
        #@scales = spec.scales or 'fixed'
        #@sizing = spec.sizing or 'fixed'
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

        # update column scales to match on x aesthetics
        _.each @xs, (x, xIdx) =>
            _.each @ys, (y, yIdx) =>
                paneScales = @subFacets[x][y].scales
                paneScales.merge colScales[xIdx], false
                paneScales.merge rowScales[yIdx], false



    renderXAxis: () ->
    renderYAxis: () ->

    render: (@width, @height, svg, data) ->
        # compute layout of the facets
        # decide if x/y labels need to be rendered
        # create the containers

        @prepare data
        # each pane's layers has trained their scales

        # add margins
        margin = @margin / 2
        matrix = "#{1.0-2*margin/@width},0,0,
            #{1.0-2*margin/@height}, #{margin}, #{margin}"
        svg = svg.append('g')
            .attr('transform', "matrix(#{matrix})")


        svg.append('rect')
            .attr('class', 'plot-background')
            .attr('fill', 'white')
            .attr('x', 0)
            .attr('y', 0)
            .attr('width', @width)
            .attr('height', @height)

        paddingY = 10
        paddingX = 10
        labelSize = 20
        labelPadding = 4
        facetSize = labelSize + labelPadding*2

        facetWidth = @width - 2*facetSize - paddingX
        facetHeight = @height - 2*facetSize
        xFacet = d3.scale.ordinal().domain(@xs).rangeBands([0, facetWidth], 0.02)
        xBand = xFacet.rangeBand()
        yFacet = d3.scale.ordinal().domain(@ys).rangeBands([0, facetHeight], 0.02)
        yBand = yFacet.rangeBand()


        xLabels = svg.append('g').attr('transform', "translate(#{paddingX+facetSize}, 0)")
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
            .attr('transform', "translate(#{facetWidth+paddingX+facetSize}, #{facetSize})")
            .selectAll("g").data(@ys, String)
        yEnter = yLabels.enter().insert('g').attr('class', 'facet-label y')
        yEnter.append('rect')
        yEnter.append('text')

        yLabels.select("text").text(String)
        yEnter.select("text")
            .attr("y", (d) -> yFacet(d) + yBand / 2)
            .attr("x", labelPadding)
        yEnter.select("rect")
            .attr("y", yFacet)
            .attr("height", yBand)
            .attr("x", 0)
            .attr("width", facetSize)




        # Now create containers for each pane
        matrix = "1,0,0,1,#{facetSize+paddingX}, #{facetSize}"
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
                if yidx == @ys.length-1
                    pane.renderXAxis cell
                if xidx == 0
                    pane.renderYAxis cell
            ###
            #colEnter.append("rect")
            .attr("x", 0)
            .attr("y", 0)
            .attr("width", xBand)
            .attr("height", yBand)
            .style("fill", "red")
            ###




        ###
        # Now render X/Y axes.  This runs after pane.render
        # because pane.scales need to be updated
        matrix = "1,0,0,1,#{facetSize+paddingX},#{facetSize+facetHeight}"
        xAxesCont = svg.append("g")
            .attr("transform", "matrix(#{matrix})")
            .attr("class", "facet-axes x")
        xAxisCont = xAxesCont.selectAll("g").data(@xs)
        xAxisEnter = xAxisCont.enter().append("g")
            .attr("transform", (d)->"translate(#{xFacet(d)},0)")
            .attr("id", (d,i)->"facet-x-axis-#{i}")
            .attr("class", "axis x")
            .attr("fill", "none")
        _.each @xs, (x, xidx)=>
            id = "#facet-x-axis-#{xidx}"
            pane = @subFacets[x][@ys[0]].renderXAxis xAxesCont.select(id)


        matrix = "1,0,0,1,#{paddingX+facetSize},#{facetSize}"
        yAxesCont = svg.append('g')
            .attr("transform", "matrix(#{matrix})")
            .attr("class", "facet-axes y")
        yAxisCont = yAxesCont.selectAll("g").data(@ys)
        yAxisEnter = yAxisCont.enter().append("g")
            .attr("transform", (d)->"translate(0, #{yFacet(d)})")
            .attr("id", (d,i)->"facet-y-axis-#{i}")
            .attr("class", "axis y")
            .attr("fill", "none")
        _.each @ys, (y, yidx)=>
            id = "#facet-y-axis-#{yidx}"
            console.log @subFacets[@xs[0]][y]
            @subFacets[@xs[0]][y].renderYAxis yAxesCont.select(id)


        ###


        return

        # OK.  layout the plot area
        # 7. render axes, ticks, labels, facet labels
        # 8. render children
    ###
        _.each facetKeys, (key) =>
            [x,y] = key
            # TODO
            svgcontainer = null
            @subFacets[x][y].render(width, height, svgcontainer)


        _.each @subFacets, (panes, x) =>
            _.each panes, (pane, y) =>
                pane.render @width, @height, svg, @facetData[x][y]
    ###

class gg.SingleFacet extends gg.GridFacet
    constructor: (@graphic, spec) ->
        super @graphic, spec


