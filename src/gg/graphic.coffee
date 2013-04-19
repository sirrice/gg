#<< gg/wf/*
#<< gg/facet
#<< gg/layer
#<< gg/scales
#<< gg/stat
#<< gg/geom

class gg.Graphic
    constructor: (@spec) ->
      @layerspec = findGood [@spec.layers, []]
      @facetspec = findGood [@spec.facets, {}]
      @scalespec = findGood [@spec.scales, {}]
      @options = findGood [@spec.opts, @spec.options, {}]

      @layers = new gg.Layers @, @layerspec
      @facets = new gg.Facets @, @facetspec
      @scales = new gg.Scales @, @scalespec


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

      _.each @facets.splitter, (node) ->
        wf.node node

      multicast = new gg.wf.Multicast
      wf.node multicast
      _.each @layers.compile(), (nodes) ->
          prev = multicast
          _.each nodes, (node) ->
              wf.connect prev, node
              prev = node

      wf

    renderGuides: -> null

    # Barrier that renders guides, title, margins, layout, etc
    layoutNode: ->
      f = (tables, envs, node) =>
        $(@svg[0]).empty()
        @svg = @svg.append("svg")
          .attr("width", @w)
          .attr("height", @h)
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
              .attr("dx", @w/2)
              .attr("dy", "1em")


        # Create container for facets
        @wFacet = @w
        @hFacet = @h - hTitle
        @svgFacet = @svg.append("g")
          .attr("transform", "translate(0, #{hTitle})")
          .attr("width", @wFacet)
          .attr("height", @hFacet)
        @renderGuides()

        tables
      new gg.wf.Barrier
        name: "layoutNode"
        f: f


    inputToTable: (input, cb) ->
      if _.isArray input
        table = gg.RowTable.fromArray input
      else if _.isSubclass input, gg.Table
        table = input
      else if _.isString input
        null
      cb table


    render: (@w, @h, @svg, input) ->
      @inputToTable input, (table) =>
        @compile()
        @workflow.run table



