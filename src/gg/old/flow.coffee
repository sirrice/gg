#<< gg/util
#<< gg/wf/xform
#<< gg/geom
class gg.FlowFactory
    constructor: (@spec, @graphic) ->

    forPane: (pane) ->
        _.map @spec, (f, idx) =>
            gg.Flow.fromSpec f, pane, idx

###
spec: [ xform | geom ]
see gg.XForm and gg.Geom for detailed specs

Flows are only created from the factory!
###
class gg.Flow
    constructor: (@spec, @xforms, @geom, @pane, @flowId) ->
        @graphic = @pane.graphic if @pane?
        @facets = @graphic.facets if @graphic?
        @scales = null
        @gmapper = @geom.mapper
        @id = gg.Flow.nextId()

    @nextId: () ->
        gg.Flow::_id += 1
    _id: 0


    @fromSpec: (spec, pane, flowId) ->
        allXforms = _.map spec, (xformSpec, i) ->
            klass = if i is spec.length-1 then gg.Geometry else gg.XForm
            klass.fromSpec xformSpec
        xforms = _.initial allXforms
        geom = _.last allXforms

        flow = new gg.Flow spec, xforms, geom, pane, flowId
        geom.flow = flow

        # TODO: support defaultmappings
        # Scales only matter for the geometry's aesthetics
        graphic = pane.graphic
        flow.scales = graphic.scaleFactory.scales geom.mapper.aesthetics(), @
        flow


    clone: -> gg.Flow.fromSpec @spec, @pane, @id

    validate: ->
        for xform, idx in @xforms
            if idx is 0 then continue
            prev = @xforms[idx-1]
            prev.outSchema
        _.every @xforms, (x) -> x.ensureSchema()

    prepare: (data) ->
        original = data
        _.each @xforms, (xform) =>
            data = xform.execute data
        @newData = _.values groupData(data, @geom.group)
        @newData = @geom.mappedData @newData
        @scales.train @newData, @

    aesthetics: -> _.without @geom.mapper.aesthetics(), 'group'
    scale: (aes) -> @scales.scale(aes)
    scaledMin: (aes) -> @scale(aes).scale @scale(aes).min
    scaledMax: (aes) -> @scale(aes).scale @scale(aes).max


    dataMin: (data, aes) ->
        if @geom.mapper.outputs aes
            key = (d) => d[aes]  #@gmapper.map d, aes
            min = (d) -> _.min d, key
            key min(_.map(data, min))
        else    # Dunno what this is
            (@statistic.dataRange data)[0]

    dataMax: (data, aes) ->
        if @geom.mapper.outputs aes
            key = (d) => d[aes]  # @gmapper.map d, aes
            max = (d) -> _.max d, key
            key max(_.map(data, max))
        else
            (@statistic.dataRange data)[1]



    render: (g) ->
        @scales.setRanges @pane
        c = g.append('g')
            .attr('id', "pane-#{@pane.id}-layer-#{@flowId}")
            .attr("class", "layer-#{@flowId}")
        console.log ['unique color vals: '].concat(_.uniq _.flatten(_.map(@newData, (data) => _.map(data, (d) => d['color']))))
        @geom.render @newData, c





