class gg.old.GridLayout
    constructor: (@spec) ->
        @nrows = 0
        @ncols = 0
        @xs = []
        @ys = []
        @mapping = {}
        @edgeOnly = true    # only labels on the edges or everywhere?

        @xRatios = null
        @yRations = null

        @xFacet = null
        @yFacet = null


        @d3ordinal = d3.scale.ordinal
        @margin = 10         # margin between cells in the layout
        @labelSize = 20     # facet label
        @labelPadding = 4
        @facetSize = @labelSize + @labelPadding * 2

    @fromSpec: (spec) ->



    add: (x, y, renderer, top=null, right=null)->
        @mapping[x] = {} if x not of @mapping
        @mapping[x][y] = {} if y not of @mapping[x]

        @mapping[x][y] = { renderer: renderer, top:top, right:right}
        @xs.push x
        @ys.push y
        @xs = _.uniq @xs
        @ys = _.uniq @ys


    widths: (width) ->

        @xRatios = _.map(@xs, () => 1.0 / @xs.length) if not @xRatios?
        if @edgeOnly
            facetWidth = width - @facetSize
            cellwidths = _.map @xRatios, (r) -> r*facetWidth
            offsets = _.map @xRatios, (r,idx) => _.sum _.first(cellwidths, idx)

            facetW = (width - @facetSize) / @xs.length
            (x) =>
                idx = _.indexOf @xs, x, true
                w = cellwidths[idx]
                w += @facetSize if idx is @xs.length-1
                [offsets[idx], w]
        else
            cellwidths = _.map @xRatios, (r) -> r*width
            offsets = _.map @xRatios, (r,idx) -> _.sum _.first(cellwidths, idx)
            (x) =>
                idx = _.indexOf @xs, x, true
                [offsets[idx], cellwidths[idx]]

    # returns function that returns [ypos, yheight]
    heights: (height) ->
        @yRatios = _.map(@ys, () => 1.0 / @ys.length) if not @yRatios?
        if @edgeOnly
            facetHeight = height - @facetSize
            chs = _.map @yRatios, (r) -> r*facetHeight
            offsets = _.map @yRatios, (r,idx) =>
                _.sum _.first(chs, idx)
            console.log "heights"
            console.log @ys
            console.log [height, facetHeight]
            console.log chs
            console.log offsets
            (y) =>
                idx = _.indexOf @ys, y, true
                if idx is 0
                    [0, chs[idx] + @facetSize]
                else
                    [@facetSize + offsets[idx], chs[idx]]
        else
            chs = _.map @yRatios, (r) -> r*height
            offsets = _.map @yRatios, (r,idx) ->
                _.sum _.first(chs, idx)
            (y) =>
                idx = _.indexOf @ys, y, true
                [offsets[idx], chs[idx]]

    renderers: ->
        _.flatten _.map(@mapping, (ytor, x) => _.map ytor, (r, y) => r)

    renderCell: (width, height, g, cellrenderer, xidx, yidx) ->
        renderer = cellrenderer.renderer
        top = cellrenderer.top
        right = cellrenderer.right
        xoffset = 0
        yoffset = 0

        topw = width
        topw -= @facetSize if xidx is @xs.length-1
        righth = height
        righty = 0
        righty += @facetSize if yidx is 0
        righth -= @facetSize if yidx is 0


        if yidx is 0 #top
            gl = g.append('g').attr('class', 'facet-label x')
            gl.append('rect')
                .attr({
                    width: topw
                    height: @facetSize
                })
            gl.append('text').text(top)
                .attr({
                    x: topw / 2
                    y: @labelPadding
                    dy: "1em"
                })
            yoffset += @facetSize
            height -= @facetSize

        if xidx is @xs.length-1 #right
            gl = g.append('g').attr('class', 'facet-label y')
            gl.append('rect')
                .attr({
                    transform: "translate(#{width-@facetSize},#{righty})"
                    width: @facetSize
                    height: righth
                })
            gl.append("text").text(right)
                .attr({
                    x: width-@facetSize+@labelPadding
                    dx: "0.5em"
                    y: righth / 2
                    rotate: 90
                })
            width -= @facetSize



        cell = g.append('g')
            .attr("transform","translate(#{xoffset},#{yoffset})")
        renderer.render width, height, cell, yidx is @ys.length-1, xidx is 0



    render: (@width, @height, g) ->
        console.log @xs
        console.log @ys
        @xs.sort()
        @ys.sort()

        @xFacet = @widths @width if not @xFacet?
        @yFacet = @heights @height if not @yFacet?

        matrix = "#{1.0-2*@facetSize/@width},0,0,
            #{1.0-2*@facetSize/@height},#{@facetSize},0"
        g = g.append('g')
            .attr('transform', "matrix(#{matrix})")

        g.append('rect')
            .attr({
                class: 'plot-background'
                x: 0
                y: 0
                width: @width
                height: @height
            })

        _.each @xs, (x, xidx) =>
            _.each @ys, (y, yidx) =>
                [xoffset, xw] = @xFacet x
                [yoffset, yh] = @yFacet y
                xoffset += @margin / 2.0
                xw -= @margin
                yoffset += @margin / 2.0
                yh -= @margin
                cell = g.append('g')
                    .attr({
                        transform: "translate(#{xoffset},#{yoffset})"
                        id: "facet-grid-#{xidx}-#{yidx}"
                        class: "facet-col-#{xidx} facet-row-#{yidx} facet-grid"
                    })

                @renderCell xw, yh, cell, @mapping[x][y], xidx, yidx


