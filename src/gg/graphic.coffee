#<< gg/facets
#<< gg/layer
#<< gg/scale
#<< gg/stats

class gg.Graphic
    constructor: (@spec) ->
        @layerspec = findGood [@spec.layers, []]
        @facetspec = findGood [@spec.facets, {}]
        @scalespec = findGood [@spec.scales, {}]
        @options = findGood [@spec.opts, @spec.options, {}]

        @layers = new gg.Layers @, @layerspec
        @facets = new gg.Facets @, @facetspec
        @scales = new gg.Scales @, @scalespec

    compile: ->
        wf = @workflow = new gg.wf.Flow


        wf.node @facets.splitter()

        multicast = new gg.wf.Multicast
        _.each @layers.compile(), (nodes) ->
            prev = multicast
            _.each nodes, (node) ->
                wf.connect prev, node
                prev = node


    render: (@w, @h, @svg, table) ->
        @compile()
        @workflow.run table


class gg.Layers
    constructor: (@g, @spec) ->
        @layers = _.each @spec, (layerspec) -> new gg.Layer layerSpec

    # @return [ [node,...], ...] a list of nodes for each layer
    compile: -> _.map @layers, (l) -> l.compile()

    layer: (layerOrSpec) ->
        @layers.push layerOrSpec


class gg.Layer
    constructor: (@g, @spec) ->

    parseSpec: (spec) ->
        if _.isArray spec
            # Explicit list of transformations
            _.map spec, (xformspec) -> gg.XForm.fromSpec xformspec
        else
            # Shorthand style similar to ggplot2
            geomSpec = findGood [spec.geom, "point"]
            statSpec = findGood [spec.stat, spec.stats, spec.statistic, "identity"]
            mapping = findGood [spec.aes, spec.aesthetic, spec.mapping, {}]
            posSpec = findGood [spec.pos, spec.position, "identity"]

            geom = gg.Geom.fromSpec @, geomSpec
            stat = gg.Stat.fromSpec @, statSpec
            pos = gg.Pos.fromSpec @, posSpec
            # what are the semantics of "mapping"?
            []


    statXforms: -> []
    geomXforms: -> []
    renderXforms: -> []
    scales: -> @g.facets.scales
    facetScales: ->

    compile: ->
        nodes = []

        nodes.push @g.scales.preStats()
        nodes.push.apply nodes, @statXforms()
        nodes.push @g.scales.postStats()
        nodes.push.apply nodes, @geomXforms()
        nodes.push @g.scales.postGeom()
        nodes.push @g.facets.render()
        nodes.push.apply nodes, @renderXforms()

        nodes


class gg.Facets
    constructor: (@g, @spec) ->

    splitter: ->
        new gg.wf.Split

    render: ->
        new gg.wf.Barrier



class gg.Scales
    constructor: (@g, @spec) ->
        @prescales
        @postscales
        @postgeom
        # need to know aesthetics and the attributes to expect!!!

        @prestatsNode = new gg.wf.Barrier {
            name: "prestats",
            f: (tables) =>
                @prescales.train tables
                tables
        }

        @poststatsNode = new gg.wf.Barrier {
            name: "poststats",
            f: (tables) =>
                @postscales.train tables
                tables
        }

        @postgeomNode = new gg.wf.Barrier {
            name: "postgeom",
            f: (tables) =>
                @postgeom.train tables
                tables
        }


    @fromSpec: (g, spec) ->
        # copy the scales object from before




# used as a router for instantiating geom/stat transformations
class gg.XForm
    @fromSpec: (spec) ->
        null

class gg.Stat
    @fromSpec: (spec) ->



class gg.Pos
    @fromSpec: (spec) ->


class gg.Graphic
    constructor: (@opts) ->
        @layersFactory = null
        @scaleFactory = null
        @spec = {}
        @facets = null
        @mapping = {} # the default mapping

        # TODO: move this into addtl parameters object!
        @opts = @opts or { padding: 0 }
        @paddingX = @opts.paddingX or @opts.padding
        @paddingY = @opts.paddingY or @opts.padding

    @fromSpec: (spec, opts) ->
        g = new gg.Graphic opts
        g.mapping = spec.mapping or {}
        g.layersFactory = new gg.LayersFactory spec.layers, g
        g.scaleFactory = new gg.ScaleFactory spec
        g.facets = gg.Facets.fromSpec spec.facets, g
        g.spec = spec
        g

    # TODO: add clone, add scales/layers/other specs

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




