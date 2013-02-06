

class gg.LayersFactory
    constructor: (@spec, @graphic) ->


    forPane: (pane) ->
        layers = _.map @spec, (l, idx) =>
            layer = gg.Layer.fromSpec l, pane, idx
            layer.pane = pane
            layer
        layers





# Layers are where data is actually processed (statistics, mappings).
# At higher levels, (e.g., Graphic, Facet) data is partitioned (but not
# transformed)
#
#
#
#<< gg/util
#<< gg/geom
class gg.Layer
    constructor: (@geometry, @pane, @id) ->
        @mappings = {}
        @statistic = null
        @spec = null
        @graphic = @pane.graphic
        @facets = @graphic.facets
        @scales = null
        # also want positioner, data
        # where is aethetic here?
        #
        @aesFunctions = {}

    @clone: ->
        gg.Layer.fromSpec @spec, @pane, @id


    @fromSpec: (spec, pane, layerId) ->
        geom = new {
            point:    gg.PointGeometry,
            line:     gg.LineGeometry,
            area:     gg.AreaGeometry,
            interval: gg.IntervalGeometry,
            box:      gg.BoxPlotGeometry,
            text:     gg.TextGeometry
        }[spec.geometry || 'point'](spec);
        graphic = pane.graphic

        geom.layer = layer = new gg.Layer geom, pane, layerId
        layer.mappings = spec.mapping if spec.mapping?
        layer.statistic = gg.Statistics.fromSpec spec.statistic or {kind: 'identity'}
        layer.spec = spec
        layer.scales = graphic.scaleFactory.scales layer.aesthetics()
        layer



    prepare: (data) ->
        # TODO: data should be grouped before computing statistics
        @newData = @statistic.compute data, @mappings
        @newData = _.values groupData(@newData, @mappings.group)
        @scales.train @newData, @

    render: (g) ->
        @scales.setRanges @pane
        @geometry.render g, @newData


    aesthetics: -> _.without _.keys(@mappings), 'group'
    scale: (aes) -> @scales.scale(aes)
    scaleExtracted: (v, aes, d) -> @scale(aes).scale v, d
    scaledValue: (d, aes) -> @scaleExtracted @dataValue(d, aes), aes, d
    scaledMin: (aes) -> @scale(aes).scale @scale(aes).min
    scaledMax: (aes) -> @scale(aes).scale @scale(aes).max

    # Extracts the mapped value for a given aesthetic
    # Performs user-defined transformations if defined
    dataValue: (datum, aes) ->
        key = @mappings[aes]

        if typeof key is 'function'
            key datum
        else if key of datum
            datum[key]
        else if aes != 'text'
            # XXX: This is risky, need to be certain that user creating plot is safe
            if not (aes of @aesFunctions)
                cmds = (_.map datum, (val, k) => "var #{k} = datum['#{k}'];")
                cmds.push "return #{key}; "
                cmd = cmds.join('')
                fcmd = "var __func__ = function(datum) {#{cmd}}"
                eval(fcmd)
                @aesFunctions[aes] = __func__
            @aesFunctions[aes](datum)
        else
            key

    dataMin: (data, aes) ->
        if aes of @mappings
            key = (d) => @dataValue d, aes
            min = (d) -> _.min d, key
            key min(_.map(data, min))
        else
            (@statistic.dataRange data)[0]

    dataMax: (data, aes) ->
        if aes of @mappings
            key = (d) => @dataValue d, aes
            max = (d) -> _.max d, key
            key max(_.map(data, max))
        else
            (@statistic.dataRange data)[1]

    legend: (aes) ->
        @mappings[aes] or @statistic.variable


