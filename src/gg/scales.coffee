#<< gg/scale



#
# This scales object manages the mapping throughout the workflow between
#
#   [facetX, facetY, layerIdx] -> trained scales object
#
# It provides the following access methods
#
#   @scales(facetX, facetY, layerIdx) --> scales
#   @scales() --> scales
#
#
# A Scale defines an invertable mapping from a Domain -> Range.
#
# Scales transform, train and map at multiple places in workflow
#
#   transform: apply scale transformation
#   untransform: apply inverse of scale transformation
#   train: learn the domains of all tables in the workflow
#   map: remove oob values, round to 500'th decimal, compute palettes, etc
#
#
# In each case, the scales _only_ train on known and supported aesthetic
# attributes that can be found in the tables
#
# !!! This means that any aesthetic mappings need to be applied before the
# barrier node that performs the training !!!
#
# Users can specify pre-statistics and post-statistics aesthetic mappings.
# By default, if users only specify one mapping, it's assumed to be pre-statistics mapping
#
# Pre-statistics: these are defined by preStats + postStats, just blindly apply
#
# Post-statistics: sometimes, the statistics will compute auxiliary attributes that the
# user wants to plot (e.g., SUM, AVG, Q1).  Rather than using the x,y
# attributes from pre-stats, the user can explicitly change the attributes to
# be used for rendering geometries.
#
class gg.Scales extends gg.XForm
  @UNTRAINED = 0
  @PREGEOM = 1
  @PRERENDER = 2
  @POSTRENDER = 3
  @POSTFACET = 4


  constructor: (@g, @spec) ->
    @scalesFactory = null
    @mappings = {}     # facetX -> facetY -> layerIdx -> scalesSet
    @scalesList = []  # list of the scalesSet objects
    @state = gg.Scales.UNTRAINED

    @parseSpec()

    # Initial training before running stats
    @prestatsNode = new gg.wf.Barrier
      name: "scales:prestats"
      f: (args...) => @trainOnData(args..., gg.Scales.PREGEOM)

    # Training after stats, before geometry section
    @pregeomNode = new gg.wf.Barrier
      name: "scales:poststats"
      f: (args...) => @trainOnData(args..., gg.Scales.PRERENDER)

    # trains scales on the pixel domain
    @prerenderNode = new gg.wf.Barrier
      name: "scales:postgeom"
      f: (args...) => @trainOnPixels(args..., gg.Scales.POSTRENDER)

    # XXX: I don't rememebr why this exists
    @facetNode = new gg.wf.Barrier
      name: "scales:facet"
      f: (args...) => @trainForFacets(args..., gg.Scales.POSTFACET)

  parseSpec: ->
    # setup the scales factory
    @scalesFactory = new gg.ScaleFactory @spec


  setMapping: (mappings, info, scales) ->
    facetX = info.facetX
    facetY = info.facetY
    layerIdx = info.layer

    mappings[facetX] = {} unless facetX of mappings
    xmappings = mappings[facetX]
    xmappings[facetY] = {} unless facetY of xmappings
    ymappings = xmappings[facetY]
    ymappings[layerIdx] = scales

  # these training methods assume that the tables's attribute names have
  # been mapped to the aesthetic attributes that the scales expect
  trainOnData: (tables, envs, node, nextState=null) ->

    mappings = {}
    scalesList = []
    _.each _.zip(tables, envs), ([t,e]) =>
      info = @paneInfo t, e
      aess = @aesthetics info.layer
      console.log "train scale aess: #{aess}"

      scales = @scales info.facetX, info.facetY, info.layer
      scales.train t, aess
      scalesList.push scales
      @setMapping mappings, info, scales

    @mappings = mappings
    @scalesList = scalesList
    @state = nextState if nextState?
    @g.facets.trainScales()
    tables


  # Train on a table that has been mapped to aesthetic domain.
  #
  # Need to invert the aesthetic columns to be in the value domain before training
  #
  trainOnPixels: (tables, envs, node, nextState=null) ->

    mappings = {}
    scalesList = []
    _.each _.zip(tables, envs), ([table,e]) =>
      t = table.cloneDeep()
      info = @paneInfo t, e
      aess = @aesthetics info.layer

      scales = @scales info.facetX, info.facetY, info.layer
      inverted = scales.invert t, aess
      scales.train inverted, aess
      scalesList.push scales
      @setMapping mappings, info, scales
      console.log "pixeltrained scales: #{scales.scale('x').domain()}"

    @mappings = mappings
    @scalesList = scalesList
    @state = nextState if nextState?
    #@g.facets.trainScales()
    tables

  trainForFacets: (tables, envs, node, nextState) ->
    unless @state is gg.Scales.POSTRENDER
      throw Error("gg.Scales.trainForFacets: state (#{@state}) != POSTRENDER")
    @g.facets.trainScales()
    @state = nextState


  layer: (layerIdx) -> @g.layers.getLayer layerIdx

  # XXX: layer aesthetics should differentiate between pre-post stats aesthetic mappings!
  aesthetics: (layerIdx) ->
    scalesAess = _.keys(@scalesFactory.paneDefaults)
    layerAess =  @layer(layerIdx).aesthetics()
    aess = _.compact _.uniq _.flatten([scalesAess, layerAess, ['y', 'x']])
    aess

  facetScales: (facetX, facetY) ->
    try
      mapping = @mappings[facetX][facetY]
      gg.ScalesSet.merge _.values(mapping)
    catch error
      throw Error("gg.ScalesfacetScales: could not find scales\n\t#{error}")

  scales: (facetX=null, facetY=null, layerIdx=null) ->
    @mappings[facetX] = {} unless facetX of @mappings
    @mappings[facetX][facetY] = {} unless facetY of @mappings[facetX]
    map = @mappings[facetX][facetY]

    if layerIdx?
      unless layerIdx of map
        aess = @aesthetics layerIdx
        map[layerIdx] = @scalesFactory.scales aess
      map[layerIdx]
    else
      _.values map

    #try
    #  if layerIdx?
    #    @mappings[facetX][facetY][layerIdx]
    #  else
    #    _.values @mappings[facetX][facetY]
    #catch error
    #  args = "#{facetX}, #{facetY}, #{layerIdx}"
    #  throw Error("gg.Scales.scales: could not find scales: #{args}\n\t#{error}")





# Convenience class that creates identical gg.Scales objects
# from a single spec
#
# Used to create layer, panel and facet level copies of gg.Scales
# when training the scales
class gg.ScaleFactory
  constructor: (@spec, @layersSpecs=[]) ->
    @paneDefaults = {}      # aes -> scale object
    @layerDefaults = {}     # [layerid,aes] -> scale object

    @setup()

  setup: ->

    # load graphic defaults
    _.each @spec, (s, aes) =>
      # XXX: notice that scale spec expects an aes key
      s = _.clone s
      s.aes = aes
      scale = gg.Scale.fromSpec s
      @paneDefaults[scale.aesthetic] = scale
      console.log "pane default: #{scale.aesthetic}\t#{s}"

    # load layer defaults
    if @layerSpecs? and @layerSpecs.length > 0
      _.each @layerSpecs, (lspec, idx) =>
        if lspec.scales?
          _.each lspec.scales, (s) =>
            scale = gg.Scale.fromSpec s
            key = [idx, scale.aesthetic]
            @layerDefaults[key] = scale

  addLayerDefaults: (layerIdx, lspec) ->
    throw Error("gg.ScaleFactory: layer scales not implemented")

  scale: (aes, layerIdx=null) ->
      if layerIdx? and [layerIdx, aes] of @layerDefaults
          @layerDefaults[[layerIdx, aes]].clone()
      else if aes of @paneDefaults
          @paneDefaults[aes].clone()
      else
          gg.Scale.defaultFor aes

  scales: (aesthetics, layerIdx=null) ->
      scales = new gg.ScalesSet @
      _.each aesthetics, (aes) =>
          scales.scale(@scale aes, layerIdx)
          console.log "made scale #{scales.scale(aes)}"
      scales





#
#
# Manage a graphic/pane/layer's set of scales
# a Wrapper around {aes -> {type -> scale} } + utility functions
#
class gg.ScalesSet
  constructor: (@factory) ->
    @scales = {}
    @spec = {}

  clone: () ->
    ret = new gg.ScalesSet @factory
    ret.spec = @spec
    ret.merge @
    ret

  # overwriting
  keep: (aesthetics) ->
    _.each _.keys(@scales), (aes) =>
        if aes not in aesthetics
            delete @scales[aes]
    @

  exclude: (aesthetics) ->
    _.each aesthetics, (aes) =>
        if aes of @scales
            delete @scales[aes]
    @

  aesthetics: ->
    keys = _.keys @scales
    _.map keys, (key) ->
      if key of gg.Scale.xs
        gg.Scale.xs
      else if key of gg.Scale.ys
        gg.Scale.ys
      else
        key
    _.uniq _.flatten keys



  ensureScales: (aess) ->
    _.each aess, (aes) =>
        @scale(gg.Scale.defaultFor aes) if ! @scale(aes)
    @


  contains: (aes, type=null) -> aes of @scales and (not type or type of @scales[aes])
  scale: (aesOrScale, type=null) ->
    if _.isString aesOrScale
        aes = aesOrScale
        aes = 'x' if aes in gg.Scale.xs
        aes = 'y' if aes in gg.Scale.ys
        @scales[aes] = {} if aes not of @scales

        if type is null
            vals = _.values @scales[aes]
            if vals? and vals.length > 0 then vals[0] else null
        else
            @scales[aes][type] = @factory.scale aes if type not of @scales[aes]
            @scales[aes][type]

    else if aesOrScale?
        scale = aesOrScale
        aes = scale.aesthetic
        @scales[aes] = {} if aes not of @scales
        @scales[aes][scale.type] = scale



  # @param scalesArr array of gg.Scales objects
  # @return a single gg.Scales object that merges the inputs
  @merge: (scalesArr) ->
    if scalesArr.length is 0
        return null
    ret = scalesArr[0].clone()
    _.each scalesArr, (scales) ->
        ret.merge scales
    ret

  # @param scales a gg.Scales object
  # @param insert should we add new aesthetics that exist in scales argument?
  # merges domains of argument scales with self
  # updates in place
  #
  merge: (scales, insert=true) ->
    _.each scales.aesthetics(), (aes) =>
      if aes is 'text'
          return

      _.each scales.scales[aes], (scale, type) =>
        if @contains aes, type
          @scale(aes, type).mergeDomain scales.scale(aes, type).domain()
        else if insert
          @scale(scales.scale(aes, type).clone())
    @


  # each aesthetic will be trained
  # multiple layers may use same aesthetics so need to cope with
  # overlaps
  train: (table, aess=null) ->
    aess = _.uniq _.keys @scales unless aess?
    _.each aess, (aes) =>
      scale = @scale(aes)

      col = table.getColumn(aes)
      # XXX: perform type checking.  Just assume all continuous for now
      if col?
        scale.mergeDomain scale.defaultDomain col
    @

  setRanges: (pane) ->
    _.each pane.aesthetics(), (aes) =>
      _.each _.values(@scales[aes]), (s) =>
        if aes in ['x', 'y']
          s.range pane.rangeFor aes
    @


  toString: ->
    arr = _.flatten _.map @scales, (map, aes) =>
        _.map map, (scale, type) =>
            d3Scale = scale.d3Scale
            _.flatten([aes, '->', type, d3Scale.domain(), d3Scale.range()]).join(' ')
    arr.join('\n')

  apply: -> null

  # destructively invert table on aess columns
  #
  # @param {gg.Table} table
  invert: (table, aess=null) ->
    aess = _.keys @scales unless aess?

    table = table.cloneShallow()
    table.each (row, idx) =>
      _.each aess, (aes) =>
        row[aes] = @scale(aes).invert(row[aes]) if aes of row
    table

  labelFor: -> null




