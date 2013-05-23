#<< gg/core/xform
#<< gg/scale/scale



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
class gg.scale.Scales extends gg.core.XForm

  constructor: (@g, @spec) ->
    super
    @scalesConfig = null
    @mappings = {}     # facetX -> facetY -> layerIdx -> scalesSet
    @scalesList = []  # list of the scalesSet objects


    @prestats = @trainDataNode
      name: "scales-prestats"
    @postgeommap = @trainDataNode
      name: "scales-postgeommap"
    @facets = @trainFacets
      name: "scales"
    @pixel = new gg.wf.Barrier
      name: "scales-pixel"
      f: (args...) => @trainOnPixels args..., spec

    @parseSpec()
    @log.level = gg.util.Log.WARN


  # XXX: assumes layers have been created already
  parseSpec: ->
    @scalesConfig = gg.scale.Config.fromSpec @spec

    # scan through @g.layers for more scales specs
    _.each @g.layers.layers, (layer) =>
      @scalesConfig.addLayerDefaults layer



  # @param spec
  #   nextState
  #   name
  #   attrToAes: mapping from table attribute to aesthetic
  #              e.g., q1 -> y, q3 -> y
  trainDataNode: (spec={}) ->
    @_trainDataNode = new gg.wf.Barrier
      name: spec.name
      f: (args...) => @trainOnData args...,spec
    @_trainDataNode

  trainPixelNode: (spec={}) ->
    @_invertPixelNode = new gg.wf.Barrier
      name: "#{spec.name}-invert"
      f: (args...) => @trainOnPixelsInvert args...,spec
    @_reapplyPixelNode = new gg.wf.Barrier
      name: "#{spec.name}-reapply"
      f: (args...) => @trainOnPixelsReapply args..., spec
    [
      @_invertPixelNode
      #new gg.wf.Stdout
      #  name: "mid-trainPixel"
      #  n: 5
      #  aess: ["x", "x0", "x1", "y", "y1"]
      @_reapplyPixelNode
    ]

  trainFacets: (spec={}) ->
    @_trainFacet = new gg.wf.Barrier
      name: "#{spec.name}-facet"
      f: (args...) => @trainForFacets args..., spec
    @_trainFacet


  # these training methods assume that the tables's attribute names
  # have been mapped to the aesthetic attributes that the scales
  # expect
  #
  # also removes invalid tuples
  trainOnData: (tables, envs, node, spec={}) ->
    _.each _.zip(tables, envs), ([t,e]) =>
      info = @paneInfo t, e
      # XXX: ack, this is just really ugly.
      # @aesthetics() is for user-specified aesthetics
      # t.colNames is for everything else
      scales = @scales info.facetX, info.facetY, info.layer

      @log "trainOnData: cols:    #{t.colNames()}"
      @log "trainOnData: set.id:  #{scales.id}"

      scales.train t, null, spec.posMapping

    @g.facets.trainScales()
    tables


  # Train on a table that has been mapped to aesthetic domain.
  #
  # This is tricky because the table has lost the original
  # data types e.g., numerical values mapped to color strings
  # - invert the table using scales retrieved with original table's
  #   data types
  #   - only invert data columns that have been mapped
  #     (how to detect this?)
  #   - only invert columns that were _originally_ numerical
  #     because they are the only scales that could expand
  #   - what about derived values? (e.g., width)
  # - reset the domains of the scales
  # - train scales now that tables are in original domain
  #
  # Need to invert the aesthetic columns to be in the value domain
  # before training
  #
  #
  trainOnPixels: (tables, envs, node, spec={}) ->
    getAessType = ([t, info]) =>
      scales = @scales info.facetX, info.facetY, info.layer
      posMapping = @posMapping info.layer

      aessTypes = {}
      # only table columns that have a corresponding
      # ordinal scale are allowed
      aessTypes = _.map t.colNames(), (aes) ->
        _.map scales.types(aes, posMapping), (type) ->
          unless type is gg.data.Schema.ordinal
            if t.contains aes, type
              {aes: aes, type: type}
      aessTypes = _.compact _.flatten aessTypes
      aessTypes


    invert = ([t, info, aessTypes]) =>
      scales = @scales info.facetX, info.facetY, info.layer
      posMapping = @posMapping info.layer
      @log "trainOnPixels: #{scales.toString("\t")}"
      @log "trainOnPixels: #{t.colNames()}"
      @log "trainOnPixels: posMapping: #{JSON.stringify posMapping}"
      @log "trainOnPixels: cols:       #{t.colNames()}"
      @log "trainOnPixels: setid:      #{scales.id}"
      @log "trainOnPixels: aesTypes:   #{JSON.stringify aessTypes}"

      inverted = scales.invert t, aessTypes, posMapping
      inverted

    reset = (info) =>
      scales = @scales info.facetX, info.facetY, info.layer
      scales.resetDomain()

    train = ([t,info, aessTypes, origSchema]) =>
      @log info
      scales = @scales info.facetX, info.facetY, info.layer
      posMapping = @posMapping info.layer
      @log posMapping
      scales.train t, aessTypes, posMapping

    apply = ([t,info, aessTypes, origSchema]) =>
      scales = @scales info.facetX, info.facetY, info.layer
      posMapping = @posMapping info.layer
      @log "trainOnPixels: #{scales.toString("\t")}"

      @log "trainOnpixels: pre-Schema: #{t.colNames()}"
      gg.wf.Stdout.print t, ['x'], 5, gg.util.Log.logger("pre-apply")
      t = scales.apply t, aessTypes, posMapping
      t.schema = origSchema
      @log "trainOnpixels postSchema: #{t.colNames()}"
      gg.wf.Stdout.print t, ['x'], 5, gg.util.Log.logger("pst-apply")
      t

    # 0) setup some variables we'll need
    infos = _.map _.zip(tables, envs), ([t,e]) => @paneInfo t, e
    originalSchemas = _.map tables, (t) -> t.schema
    allAessTypes = _.map _.zip(tables, infos), getAessType

    # 1) invert the table columns
    inverteds = _.map _.zip(tables, infos, allAessTypes), invert

    args = _.zip(inverteds, infos, allAessTypes, originalSchemas)
    # 2) retrain the scales' domains
    _.each infos, reset
    _.each args, train
    # XXX: this is dangerous call, because it's not idempotent
    @g.facets.trainScales()

    # 3) re-apply scales to inverted tables
    newTables = _.map args, apply

    _.each infos, (info) =>
      scales = @scales info.facetX, info.facetY, info.layer
      @log.warn "Trained scales. #{JSON.stringify info}"
      _.each [0,1,2], (v) =>
        newv = scales.scale('x', gg.data.Schema.unknown).scale v
        @log.warn "\t#{v} -> #{newv}"


    newTables


  trainForFacets: (tables, envs, node) ->
    @g.facets.trainScales()
    tables


  layer: (layerIdx) -> @g.layers.getLayer layerIdx


  posMapping: (layerIdx) -> @layer(layerIdx).geom.posMapping()

  # XXX: layer aesthetics should differentiate between
  #      pre and post stats aesthetic mappings!
  aesthetics: (layerIdx) ->
    throw Error("gg.Scales.aesthetics not implemented")
    scalesAess = []#@scalesConfig.aesthetics()
    layerAess =  @layer(layerIdx).aesthetics()
    # XXX: incorporate coordinate based x/y attributes instead
    aess = [scalesAess, layerAess, gg.scale.Scale.xys]
    _.compact _.uniq _.flatten aess

  # return the overall scalesSet for a given facet
  facetScales: (facetX, facetY) ->
    try
      scaleSets = @scales facetX, facetY
      ret = gg.scale.Set.merge scaleSets
      ret
    catch error
      throw Error("gg.Scales.facetScales: not scales found\n\t#{error}")

  # retrieve all scales sets for a facet pane, or a specific
  # layer's scales set
  scales: (facetX=null, facetY=null, layerIdx=null) ->
    @mappings[facetX] = {} unless facetX of @mappings
    @mappings[facetX][facetY] = {} unless facetY of @mappings[facetX]
    map = @mappings[facetX][facetY]

    if layerIdx?
      unless layerIdx of map
        #aess = @aesthetics layerIdx
        aess = []
        # XXX: support other factories for per-layer scales
        newScalesSet = @scalesConfig.scales layerIdx
        map[layerIdx] = newScalesSet
        @scalesList.push newScalesSet
      map[layerIdx]
    else
      _.values map














