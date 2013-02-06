#<< gg/facets
#<< gg/layer
#<< gg/scale
#<< gg/stats
class gg.Graphic
    constructor: (@opts) ->
        @layersFactory = null
        @scaleFactory = null
        @spec = {}
        @facets = null

        # TODO: move this into addtl parameters object!
        @opts = @opts or { padding: 0 }
        @paddingX = @opts.paddingX or @opts.padding
        @paddingY = @opts.paddingY or @opts.padding

    @fromSpec: (spec, opts) ->
        g = new gg.Graphic opts
        g.layersFactory = new gg.LayersFactory spec.layers, g
        g.scaleFactory = new gg.ScaleFactory spec
        g.facets = gg.Facets.fromSpec spec.facets, g
        g.spec = spec
        g

    render: (w, h, where, data) ->
        [@width, @height] = [w, h]
        @svg = where.append('svg')
            .attr('width', @width)
            .attr('height', @height)

        @facets.prepare data

        legendAess = _.intersection @facets.masterScales.aesthetics(), gg.Scale.legendAess
        console.log ""+@facets.masterScales
        console.log legendAess
        _.each legendAess, (aes) =>
            console.log @legend aes
            s = @facets.masterScales.scale(aes)
            console.log s

        # Allocate space for title, subtitle, legend
        @facets.render w, h, @svg, data


    # Wrapper to bind @render with default settings
    renderer: (w, h, where) -> (data) => @render w, h, where, data
    layer: (e) -> @layers.push e
    legend: (aes) ->
        # TODO: consolidate scales from facets
        @facets.panes[0].layers[0].legend aes
        #.scale(aes).legend or @layers[0].legend aes




