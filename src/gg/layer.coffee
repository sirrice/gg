#<< gg/util
#<< gg/geom
class gg.Layer
    constructor: (@geometry, @graphic) ->
        @mappings = {}
        @statistic = null
        # also want positioner, data
        # where is aethetic here?

    @fromSpec: (spec, graphic) ->
        geom = new {
            point:    gg.PointGeometry,
            line:     gg.LineGeometry,
            area:     gg.AreaGeometry,
            interval: gg.IntervalGeometry,
            box:      gg.BoxPlotGeometry,
            text:     gg.TextGeometry
        }[spec.geometry || 'point'](spec);

        geom.layer = layer = new gg.Layer geom, graphic
        layer.mappings = spec.mapping if spec.mapping?
        layer.statistic = gg.Statistics.fromSpec spec.statistic or {kind: 'identity'}
        layer

    aesthetics: () -> _.without _.keys(@mappings), 'group'

    trainScales: (newData) ->
        _.each @aesthetics(), (aes) =>
            s = @graphic.scales[aes]

            # TODO: domains of diff layers could be different!  Need to
            # normalize the domains
            if aes is 'text'
                s.prepare @, newData, aes
            else
                if !s.domainSet
                    s.defaultDomain @, newData, aes
                if aes in ['x', 'y']
                    s.range @graphic.rangeFor(aes)

    prepare: (data) ->
        @newData = @statistic.compute data, @mappings
        @newData = _.values groupData(@newData, @mappings.group)
        @trainScales @newData

    render: (g) -> @geometry.render g, @newData


    scaleExtracted: (v, aes, d) -> @graphic.scales[aes].scale v, d
    scaledValue: (d, aes) -> @scaleExtracted @dataValue(d, aes), aes, d
    scaledMin: (aes) -> @graphic.scales[aes].scale @graphic.scales[aes].min

    dataValue: (datum, aes) ->
        # TODO: this is where aes functions would go
        #       otherwise, data xforms should be done in Statistics
        datum[@mappings[aes]]

    dataMin: (data, aes) ->
        if @mappings[aes]
            key = (d) => @dataValue d, aes
            min = (d) -> _.min d, key
            key min(_.map(data, min))
        else
            (@statistic.dataRange data)[0]

    dataMax: (data, aes) ->
        if @mappings[aes]
            key = (d) => @dataValue d, aes
            max = (d) -> _.max d, key
            key max(_.map(data, max))
        else
            (@statistic.dataRange data)[1]

    legend: (aes) ->
        @mappings[aes] or @statistic.variable


