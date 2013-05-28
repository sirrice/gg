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
    @log.level = gg.util.Log.DEBUG
    @log.logname = "Scales"


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
  trainOnData: (tables, envs, node, spec={}) ->
    fTrain = ([t,e]) =>
      info = @paneInfo t, e
      scales = @scales info.facetX, info.facetY, info.layer

      @log "trainOnData: cols:    #{t.schema.toSimpleString()}"
      @log "trainOnData: set.id:  #{scales.id}"

      scales.train t, null, spec.posMapping

    @mappings = {}
    @scalesList = []
    _.each _.zip(tables, envs),fTrain
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
    # 0) copy existing scales
    # 1) iterate through each column, compute bounds
    # 2) invert bounds
    # 3) merge bounds with existing scales
    # 4) map tables once to invert using old scales + apply new scales

    fAessType = ([t, info]) =>
      scales = @scales info.facetX, info.facetY, info.layer
      posMapping = @posMapping info.layer
      # only table columns that have a corresponding
      # ordinal scale are allowed
      f = (aes) ->
        _.map scales.types(aes, posMapping), (type) =>
          unless type is gg.data.Schema.ordinal
            if t.contains aes, type
              {aes: aes, type: type}

      _.compact _.flatten _.map t.colNames(), f

    fOldScaleSet = (info) =>
      scales = @scales info.facetX, info.facetY, info.layer
      scales = scales.clone()
      scales


    fMergeDomain = ([t, info, aessTypes]) =>
      scales = @scales info.facetX, info.facetY, info.layer
      posMapping = @posMapping info.layer
      f = (table, scale, aes) =>
        col = table.getColumn(aes)
        col = col.filter _.isValid
        return unless col? and col.length > 0

        # col has pixel (range) units
        range = scale.defaultDomain col
        domain = _.map range, (v) ->
          if v? then scale.invert v else null
        scale.mergeDomain domain
        @log "merge: #{aes}\trange: #{range}"
        @log "merge: #{aes}\tdomain: #{domain}"
        @log "merge: #{scale.toString()}"

      scales.useScales t, aessTypes, posMapping, f

    fRescale = ([t, info, aessTypes, oldScales]) =>
      scales = @scales info.facetX, info.facetY, info.layer
      posMapping = @posMapping info.layer
      mappingFuncs = {}
      rescale = (table, scale, aes) =>
        oldScale = oldScales.scale aes, scale.type
        g = (v) -> scale.scale oldScale.invert(v)
        mappingFuncs[aes] = g
        @log "rescale: old: #{oldScale.toString()}"
        @log "rescale: new: #{scale.toString()}"


      scales.useScales t, aessTypes, posMapping, rescale
      clone = t.clone()
      clone.map mappingFuncs
      clone.schema = t.schema
      clone

    # 0) setup some variables we'll need
    infos = _.map _.zip(tables, envs), ([t,e]) => @paneInfo t, e
    allAessTypes = _.map _.zip(tables, infos), fAessType
    oldScaleSets = _.map infos, fOldScaleSet
    args = _.zip(tables, infos, allAessTypes, oldScaleSets)

    # 1) compute new scales
    _.each args, fMergeDomain

    # 2) retrain scales across facets/layers and expand domains
    #    must be done before rescaling!
    @g.facets.trainScales()

    # 3} invert data using old scales, then apply new scales
    newTables = _.map args, fRescale

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














