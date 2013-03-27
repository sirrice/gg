#<< gg/util




class gg.Layer
    constructor: (@g, @spec={}) ->

      # which index in the specification
      @layerIdx = @spec.layerIdx if @spec.layerIdx?
      @type = "node"
      @name = findGood [@spec.name, "node-#{@id}"]

      @mapper = null
      @stats = []
      @geoms = []
      @renders = []
      @flow = []
      @labeler = new gg.wf.Label
        key: "layer"
        val: @layerIdx

      @parseSpec()

    @id: -> gg.wf.Node::_id += 1
    _id: 0



    # every transform is decoupled into the series:
    # - mapping
    # - split?
    # - exec
    # - join?
    #
    # Mapping exists if there are any aesthetic mappings
    # Split/Join will exist if there is an explicit/implicit grouping
    #
    # TODO: figure out how to programatically change ala ggplot2
    #
    parseSpec: ->
      spec = @spec
      if _.isArray spec
        throw Error("layer currently only supports shorthand style")
        @parseArraySpec spec
      else
        # Shorthand style similar to ggplot2
        console.log "shorthand"
        console.log @spec
        statSpec = findGood [spec.stat, spec.stats, spec.statistic, "identity"]
        mappingSpec = findGood [spec.aes, spec.aesthetic, spec.mapping, {}]
        geomSpec =
          geom: findGood [spec.geom, "point"]
          pos: findGood [spec.pos, spec.position, "identity"]


        # NOTE: mapper defines the initial aesthetics mapping
        console.log "mapperSpec: #{JSON.stringify mappingSpec}"
        @mapper = new gg.Mapper @g, {aes: mappingSpec}
        @stats = [gg.Stat.fromSpec(@, statSpec)]
        @geom = gg.Geom.fromSpec @, geomSpec

      @flow = _.flatten [@stats, @geom.compile()]

    xformToString: (xform) ->
      if _.isSubclass xform, gg.Stat
        "S"
      else if _.isSubclass xform, gg.Mapper
        "M"
      else if _.isSubclass xform, gg.Position
        "P"
      else if _.isSubclass xform, gg.GeomRender
        "R"
      else if _.isSubclass xform, gg.Geom
        "G"

    parseArraySpec: (spec) ->
      # Explicit list of transformations
      # ensure that the list ends with geom/render nodes
      @xforms = _.map spec, (xformspec) -> gg.XForm.fromSpec xformspec
      klasses = _.map @xforms, (xform) => @xformToString xform
      klassStr = klasses.join ""
      validregex = /^([MS]*)(G|(?:M?P?R))$/
      unless regex.test klassStr
        throw Error("Layer: series of XForms not valid (#{klassStr})")

      [entireStr, statChars, geomChars] = validregex.exec(klassStr)
      [sidx, eidx] = [s, statChars.length()]
      @stats = @xforms[sidx...eidx]
      [sidx, eidx] = [eidx, eidx+geomChars.length()]
      throw Error("gg.Geom.parseArraySpec: not implemented. Needs to be thought through")
      @geoms = @xforms[sidx...eidx]
      if geomChars is "G"
        geom = @geoms[0]
        @geoms = [geom.mappingXForm(), geom.positionXForm()]
        @renders = [geom.renderXForm()]
      else
        @renders = [_.last @geoms]
        @geoms = _.initial @geoms


    # TODO: merge pre and post stats aesthetic mappings so we can train properly
    #       currently only supports pre-stats mapping
    aesthetics: -> if @mapper? then  @mapper.aesthetics else []


    # add layerIdx to environment so xforms can track it
    labelerXForm: -> [@labeler]
    # initial aesthetics mapping
    mapXForm: ->  @compileXForms [@mapper]
    # statistics
    statXForms: -> @compileXForms @stats
    # map + position
    geomXForms: -> @compileXForms [@geom]
    # geom-rendering
    renderXForms: -> @compileXForms @renders
    scales: ->
      @g
      throw Error("gg.Layer.scales not implemented")# @g.scales.getLayerScales(@)

    compileXForms: (xforms) ->
      _.flatten(_.map _.compact(xforms), (xform) -> xform.compile())

    compile: ->
      console.log "layer.compile called"
      nodes = []

      nodes.push @labelerXForm()
      # stats: pre-stats aesthetics mapping
      nodes.push @mapXForm()
      # scales: train scales (inputs are data values)
      nodes.push @g.scales.prestatsNode
      nodes.push @statXForms()

      nodes.push @g.facets.labelers
      nodes.push new gg.wf.Stdout {name: "pre-geom", n: 10}


      # geom: map attributes to aesthetic names, and to pixels
      nodes.push @geom.mappingXForm()
      # scales: train scales after the final aesthetic mapping (inputs are data values)
      nodes.push @g.scales.pregeomNode
      nodes.push new gg.wf.Stdout {name: "post-geom", n: 10}

      # layout the overall graphic, allocate space for facets
      nodes.push @g.layoutNode()
      # facets: allocate containers and compute ranges for the scales
      nodes.push @g.facets.allocatePanesNode()

      # geom: facets have set the ranges so transform data values to pixel values
      nodes.push new gg.wf.Stdout {name: "pre-pixel", n: 10}
      nodes.push @geom.transformDomainXForm()
      nodes.push new gg.wf.Stdout {name: "topixel", n: 10}
      # geom: position transformation
      nodes.push @geom.positionXForm()

      # facets: retrain scales (inputs are pixel values)
      #nodes.push new gg.wf.Stdout {name: "pre-render"}
      #nodes.push @g.scales.prerenderNode
      #nodes.push new gg.wf.Stdout {name: "prerender"}
      # coord: pixel -> domain -> transformed -> pixel XXX: not implemented

      # facets: render axes  XXX: not implemented
      # nodes.push @g.facets.renderPanes()
      # render: render geometries
      nodes.push new gg.wf.Stdout {name: "position pixel", n: 10}
      nodes.push @geom.renderXForm()


      nodes = _.compact _.flatten(nodes)
      console.log "returing nodes"
      nodes




