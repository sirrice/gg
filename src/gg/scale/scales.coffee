#<< gg/core/xform
#<< gg/scale/scale
#<< gg/scale/train/*



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


class gg.scale.Scales

  constructor: (@g, @spec) ->
    @scalesConfig = null
    @mappings = {}     # facetX -> facetY -> layerIdx -> scalesSet
    @scalesList = []  # list of the scalesSet objects
    @parseSpec()


    @prestats = new gg.scale.train.Data @g,
      name: 'scales-prestats'
      scalesConfig: @scalesConfig
    @postgeommap = new gg.scale.train.Data @g,
      name: 'scales-postgeommap'
      scalesConfig: @scalesConfig
    @facets = new gg.scale.train.Master @g,
      name: 'scales-facet'
    @pixel = new gg.scale.train.Pixel @g,
      name: 'scales-pixel'
      scalesConfig: @scalesConfig


    @log = gg.util.Log.logger("scales")
    @log.level = gg.util.Log.DEBUG


  # XXX: assumes layers have been created already
  parseSpec: ->
    @scalesConfig = gg.scale.Config.fromSpec @spec

    # scan through @g.layers for more scales specs
    _.each @g.layers.layers, (layer) =>
      @scalesConfig.addLayerDefaults layer


  layer: (layerIdx) -> @g.layers.getLayer layerIdx

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














