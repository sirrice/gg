#<< gg/facets
#<< gg/layer
#<< gg/scale
#<< gg/stats
class gg.Graphic
    constructor: (@opts) ->
        @layers = []
        @scales = {}
        # @statistics ?

        @opts = @opts or { padding: 35 }
        # TODO: move this into addtl parameters object!
        @paddingX = @opts.paddingX or @opts.padding
        @paddingY = @opts.paddingY or @opts.padding

    @fromSpec: (spec, opts) ->
        g = new gg.Graphic opts
        _.each spec.layers, (s) -> g.layer(gg.Layer.fromSpec s, g)
        _.each spec.scales, (s) -> g.scale(gg.Scale.fromSpec s)
        g.facets = gg.Facets.fromSpec spec.facets, g
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
                @scales[aes] = gg.Scale.defaultFor aes

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

    # Wrapper to bind @render with default settings
    renderer: (w, h, where) -> (data) => @render w, h, where, data
    layer: (e) -> @layers.push e
    scale: (s) -> @scales[s.aesthetic] = s
    legend: (aes) -> @scales[aes].legend or @layers[0].legend aes


