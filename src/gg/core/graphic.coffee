#<< gg/core/options
#<< gg/wf/*
#<< gg/data/*
#<< gg/facet/facet
#<< gg/layer/layers
#<< gg/scale/scales
#<< gg/stat/stat
#<< gg/geom/geom

class gg.core.Graphic
    constructor: (@spec) ->
      @aesspec = _.findGoodAttr @spec, ["aes", "aesthetic", "mapping"], {}
      @layerspec = _.findGood [@spec.layers, []]
      @facetspec = @spec.facets || @spec.facet || {}
      @scalespec = _.findGood [@spec.scales, {}]
      @optspec = _.findGood [@spec.opts, @spec.options, {}]

      @layers = new gg.layer.Layers @, @layerspec
      @facets = gg.facet.Facets.fromSpec @, @facetspec
      @scales = new gg.scale.Scales @, @scalespec
      @options = new gg.core.Options @, @optspec


    svgPane: (facetX, facetY, layer) ->
      @facets.svgPane(facetX, facetY, layer)

    # XXX: graphic object responsible for
    #
    #   1. getting scales
    #   2. getting svg containers (+ width/height layout constraints)


    compile: ->
      wf = @workflow = new gg.wf.Flow {
          g: @
      }

      #
      # pre-filter transformations??
      #

      prev = null
      for node in @facets.splitter
        wf.node node
        wf.connectBridge prev, node if prev?
        wf.connect prev, node if prev?
        prev = node


      multicast = new gg.wf.Multicast
      wf.node multicast
      wf.connectBridge prev, multicast if prev?
      wf.connect prev, multicast if prev?

      _.each @layers.compile(), (nodes) ->
        prev = multicast
        for node in nodes
          wf.connect prev, node
          prev = node

        prev = multicast
        for node in nodes
          unless _.isSubclass node, gg.wf.Barrier
            wf.connectBridge prev, node
            prev = node


      wf

    renderGuides: -> null

    # Barrier that renders guides, title, margins, layout, etc
    layoutNode: ->
      f = (tables, envs, node) =>
        $(@svg[0]).empty()
        @svg = @svg.append("svg")
          .attr("width", @options.w)
          .attr("height", @options.h)
        @svg.append("rect")
          .attr("class", "graphic-background")
          .attr("width", "100%")
          .attr("height", "100%")

        # height of title TODO: use _.exSize or _.fontSize instead
        # Draw Title.  Draw last so it's at the top
        title = @options.title
        hTitle = 0
        if title?
          hTitle = _.exSize({"font-size": "30pt"}).h
          svgTitle = @svg.append("g")
            .append("text")
              .text(title)
              .attr("text-anchor", "middle")
              .attr("class", "graphic-title")
              .attr("style", "font-size: 30pt")
              .attr("dx", @options.w/2)
              .attr("dy", "1em")


        # Create container for facets
        @wFacet = @options.w
        @hFacet = @options.h - hTitle
        @svgFacet = @svg.append("g")
          .attr("transform", "translate(0, #{hTitle})")
          .attr("width", @wFacet)
          .attr("height", @hFacet)
        @renderGuides()

        tables

      unless @_layoutNode?
        @_layoutNode = new gg.wf.Barrier
          name: "layoutNode"
          f: f
      @_layoutNode


    inputToTable: (input, cb) ->
      if _.isArray input
        table = gg.data.RowTable.fromArray input
      else if _.isSubclass input, gg.data.Table
        table = input
      else if _.isString input
        null
      cb table


    render: (@svg, input) ->
      @inputToTable input, (table) =>
        @compile()
        @workflow.run table



