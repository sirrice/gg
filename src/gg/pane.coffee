# Pane is responsible for rendering the scales and contents of a single
# plot
class gg.Pane
    constructor: (@facet, @scales) ->
        @graphic = @facet.graphic
        @id = gg.Pane.nextId()
        @layers = @graphic.layersFactory.forPane @
        @scales = @graphic.scaleFactory.scales @aesthetics


    @nextId: () ->
        gg.Pane::_id += 1
    _id: 0

    aesthetics: () -> _.union(_.flatten(_.invoke @layers, 'aesthetics'))

    rangeFor: (aes) ->
        if aes is 'x'
            [@graphic.paddingX, @width - @graphic.paddingX]
        else if aes is 'y'
            [@height - @graphic.paddingY, @graphic.paddingY]
        else
            throw "Only 2d graphics supported.  Unknown aes: #{aes}"

    scale: (aes, type=null) -> @scales.scale(aes, type)

    prepare: (data) ->
        _.each @layers, (l) -> l.prepare(data)

        # conflicting aesthetics (key,d on [aes, scale.type]) need to be merged
        _.each @layers, (l) =>
            @scales.merge l.scales


        # ok, now update each layer's scales?
        _.each @layers, (l) =>
            l.scales.merge @scales


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

    renderXAxis: (svg, text=true) ->
        xAxis = d3.svg.axis()
            .scale(@scale('x').d3Scale)
            .ticks(5)
            .tickSize(2*@graphic.paddingY - @height)
            .orient('bottom')

        if not text
            xAxis.tickFormat('')

        svg.append('g')
            .attr('class', 'x axis')
            .attr('fill', 'none')
            .attr('transform', "translate(0, #{@height-@graphic.paddingY})")
            .call(xAxis)


    renderYAxis: (svg, text) ->
        yAxis = d3.svg.axis()
            .scale(@scale('y').d3Scale)
            .ticks(5)
            .tickSize(2*@graphic.paddingX - @width)
            .orient('left')

        if not text
            yAxis.tickFormat('')

        svg.append('g')
            .attr('class', 'y axis')
            .attr('fill', 'none')
            .attr('transform', "translate(#{@graphic.paddingX},0)")
            .call(yAxis)





    render: (@width, @height, svg, data) ->

        @scales.setRanges @

        # @scales may have been trained by gg.Facets,
        # so update @layers scales
        _.each @layers, (l) =>
            l.scales.merge @scales



        svg.append('rect')
            .attr('class', 'base')
            .attr('fill', 'white')
            .attr('x', 0)
            .attr('y', 0)
            .attr('width', @width)
            .attr('height', @height)




        # each layer draws their contents
        _.each @layers, (layer) => layer.render svg.append('g')




