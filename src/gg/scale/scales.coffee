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
  @ggpackage = "gg.scale.Scales"

  constructor: (@g) ->
    @scalesConfig = gg.scale.Config.fromSpec {}
    @mappings = {}     # facetX -> facetY -> layerIdx -> scalesSet
    @scalesList = []  # list of the scalesSet objects

    @prestats = new gg.scale.train.Data(
      name: 'scales-prestats'
      params:
        config: @scalesConfig).compile()
    @postgeommap = new gg.scale.train.Data(
      name: 'scales-postgeommap'
      params:
        config: @scalesConfig).compile()
    @facets = new gg.scale.train.Master(
      name: 'scales-facet').compile()
    @pixel = new gg.scale.train.Pixel(
      name: 'scales-pixel'
      params:
        scaleTrain: @g.facets.scales
        config: @scalesConfig).compile()

    @log = gg.util.Log.logger @ggpackage, "scales"
    @log.level = gg.util.Log.DEBUG

  # retrieve all scales sets for a facet pane, or a specific
  # layer's scales set
  scales: (facetX=null, facetY=null, layerIdx=null) ->
    throw Error "scales.scales not implemented"
