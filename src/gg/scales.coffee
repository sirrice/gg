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
    super
    @scalesFactory = null
    @mappings = {}     # facetX -> facetY -> layerIdx -> scalesSet
    @scalesList = []  # list of the scalesSet objects
    @state = gg.Scales.UNTRAINED

    @parseSpec()


  parseSpec: ->
    # setup the scales factory
    # XXX: we probably want different scale factories per layer
    @scalesFactory = new gg.ScaleFactory @spec

  # @param spec
  #   nextState
  #   name
  #   attrToAes: mapping from table attribute to aesthetic
  #              e.g., q1 -> y, q3 -> y
  trainDataNode: (spec={}) ->
    new gg.wf.Barrier
      name: spec.name
      f: (args...) => @trainOnData args...,spec

  trainPixelNode: (spec={}) ->
    new gg.wf.Barrier
      name: spec.name
      f: (args...) => @trainOnPixels args...,spec


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
      aess = t.colNames()
      scales = @scales info.facetX, info.facetY, info.layer

      console.log "Scales.trainOnData table:      #{t.colNames()}"
      console.log "Scales.trainOnData scaleSet.id #{scales.id}"
      console.log "Scales.trainOnData aes         #{aess}"

      scales.train t, aess, spec.posMapping

    @state = spec.nextState if spec.nextState?
    @g.facets.trainScales()
    tables

  ###
      filtered = t.filter (row) =>
        f = (aes) => not scales.scale(aes).valid row.get(aes)
        filteredAess = aess.filter f
        filteredAess.length is 0
  ###

  # Train on a table that has been mapped to aesthetic domain.
  #
  # Need to invert the aesthetic columns to be in the value domain
  # before training
  #
  trainOnPixels: (tables, envs, node, spec={}) ->
    inverteds = _.map _.zip(tables, envs), ([t,e]) =>
      info = @paneInfo t, e
      #aess = @aesthetics info.layer
      aess = _.compact _.flatten [aess, t.colNames()]

      scales = @scales info.facetX, info.facetY, info.layer

      console.log "Scales.trainOnPixels table:      #{t.colNames()}"
      console.log "Scales.trainOnPixels scaleSet.id (#{scales.id})"
      console.log "Scales.trainOnPixels inverted aes #{aess}"

      inverted = scales.invert t, aess, spec.posMapping
      _.each scales.scalesList(), (scale) -> scale.resetDomain()
      scales.train inverted, aess, spec.posMapping
      inverted

    newTables = _.map _.zip(tables, inverteds, envs), ([t,i,e]) =>
      info = @paneInfo t, e
      aess = @aesthetics info.layer
      aess = _.compact _.flatten _.union(aess, t.colNames())

      scales = @scales info.facetX, info.facetY, info.layer
      scales.apply i, aess, spec.posMapping


    @state = spec.nextState if spec.nextState?
    @g.facets.trainScales()
    newTables

  trainForFacets: (tables, envs, node, nextState) ->
    @g.facets.trainScales()
    @state = nextState


  layer: (layerIdx) -> @g.layers.getLayer layerIdx

  # XXX: layer aesthetics should differentiate between
  #      pre and post stats aesthetic mappings!
  aesthetics: (layerIdx) ->
    scalesAess = @scalesFactory.aesthetics()
    layerAess =  @layer(layerIdx).aesthetics()
    # XXX: incorporate coordinate based x/y attributes instead
    aess = [scalesAess, layerAess, gg.Scale.xys]
    _.compact _.uniq _.flatten aess

  # return the overall scalesSet for a given facet
  facetScales: (facetX, facetY) ->
    try
      scaleSets = @scales facetX, facetY
      ret = gg.ScalesSet.merge scaleSets
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
        aess = @aesthetics layerIdx
        # XXX: support other factories for per-layer scales
        newScalesSet = @scalesFactory.scales aess
        map[layerIdx] = newScalesSet
        @scalesList.push newScalesSet
      map[layerIdx]
    else
      _.values map





# Convenience class that creates identical gg.Scales objects
# from a single spec
#
# Used to create layer, panel and facet level copies of gg.Scales
# when training the scales
#
# spec:
#
# {
#   aes: SCALESPEC
# }
#
# SCALESPEC:
# {
#   aes: aes
#   type: "linear"|"log"|...
#   limit:
#   breaks:
#   label:
# }
#
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
      @paneDefaults[scale.aes] = scale

    # load layer defaults
    if @layerSpecs? and @layerSpecs.length > 0
      _.each @layerSpecs, (lspec, idx) =>
        if lspec.scales?
          _.each lspec.scales, (s) =>
            scale = gg.Scale.fromSpec s
            key = [idx, scale.aes]
            @layerDefaults[key] = scale

  aesthetics: -> _.compact _.keys @paneDefaults

  addLayerDefaults: (layerIdx, lspec) ->
    throw Error("gg.ScaleFactory: layer scales not implemented")

  scale: (aes, layerIdx=null) ->
    scale = (
      if layerIdx? and [layerIdx, aes] of @layerDefaults
        @layerDefaults[[layerIdx, aes]].clone()
      else if aes of @paneDefaults
        @paneDefaults[aes].clone()
      else
        gg.Scale.defaultFor aes
    )
    scale


  scales: (aesthetics, layerIdx=null) ->
      scales = new gg.ScalesSet @
      _.each aesthetics, (aes) =>
          scales.scale(@scale aes, layerIdx)
          if typeof aes is "undefined"
            throw Error()
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
    @id = gg.ScalesSet::_id
    gg.ScalesSet::_id += 1
  _id: 0

  clone: () ->
    ret = new gg.ScalesSet @factory
    ret.spec = _.clone @spec
    ret.merge @, yes
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
    keys = _.map keys, (key) ->
      if key in gg.Scale.xs
        gg.Scale.xs
      else if key in gg.Scale.ys
        gg.Scale.ys
      else
        key
    _.uniq _.compact _.flatten keys



  ensureScales: (aess) ->
    _.each aess, (aes) =>
        @scale(gg.Scale.defaultFor aes) if ! @scale(aes)
    @


  contains: (aes, type=null) -> aes of @scales and (not type or type of @scales[aes])
  types: (aes) -> if aes of @scales then _.keys @scales[aes] else []
  scale: (aesOrScale, type=null) ->
    if _.isString aesOrScale
        aes = aesOrScale
        aes = 'x' if aes in gg.Scale.xs
        aes = 'y' if aes in gg.Scale.ys
        @scales[aes] = {} if aes not of @scales

        if type is null
          if type of @scales[aes]
            @scales[aes][type]
          else
            vals = _.values @scales[aes]
            unless vals? and vals.length > 0
              @scales[aes][null] = @factory.scale aes
            (_.values @scales[aes])[0]
        else
          unless type of @scales[aes]
            @scales[aes][type] = @factory.scale aes
          @scales[aes][type]

    else if aesOrScale?
      scale = aesOrScale
      aes = scale.aes
      @scales[aes] = {} unless aes of @scales
      @scales[aes][scale.type] = scale
      @scales[aes][null] = scale unless null of @scales[aes]
      console.log "gg.ScaleSet.scale#{@id} setting #{aes}-#{scale.type} to #{scale.toString()}" if aes is 'x'
      scale

  scalesList: -> _.map @aesthetics(), (aes) => @scale(aes)




  # @param scalesArr array of gg.Scales objects
  # @return a single gg.Scales object that merges the inputs
  @merge: (scalesArr) ->
    return null if scalesArr.length is 0

    ret = scalesArr[0].clone()
    _.each _.rest(scalesArr), (scales) -> ret.merge scales
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
        return unless scale.domainUpdated

        if @contains aes, type
          mys = @scale aes, type
          @scale(aes, type).mergeDomain scale.domain()
        else if @contains aes
          mys = @scale aes
          @scale(aes).mergeDomain scale.domain()
        else if insert
          @scale scale.clone(), type

        mys = @scale aes, type

    @


  # each aesthetic will be trained
  # multiple layers may use same aesthetics so need to cope with
  # overlaps
  # @param posMapping maps table attr to aesthetic with scale
  #        attr -> aes
  #        attr -> [aes, type]
  train: (table, aess=null, posMapping={}) ->
    aess = _.uniq _.keys @scales unless aess?
    console.log "gg.ScalesSet.train aess #{aess}"
    _.each aess, (aes) =>
      scale = @scale(posMapping[aes] or aes)

      col = table.getColumn(aes)
      # XXX: perform type checking.  Just assume all
      #      continuous for now
      if col?
        scale.mergeDomain scale.defaultDomain col
      else if table.nrows() > 0
        console.log "scalesSet.train: #{aes} not in table:
          #{table.colNames()}!"
    @


  toString: ->
    arr = _.flatten _.map @scales, (map, aes) =>
        _.map map, (scale, type) => scale.toString()
    arr.join('\n')

  # @param posMapping maps aesthetic names to the scale that
  #        should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  apply: (table, aess=null, posMapping={}) ->
    aess = @aesthetics() unless aess?

    table = table.clone()
    _.each aess, (aes) =>
      scale = @scale(posMapping[aes] or aes)
      f = (v) -> scale.scale v
      table.map f, aes if table.contains aes

    table

  # @param posMapping maps aesthetic names to the scale that should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  # @param {gg.Table} table
  invert: (table, aess=null, posMapping={}) ->
    aess = @aesthetics() unless aess?
    console.log "gg.ScaleSet.invert: aess #{aess} table #{table.colNames()}"

    newTable = table.clone()
    _.each aess, (aes) =>
      scale = @scale(posMapping[aes] or aes)
      console.log "gg.ScaleSet.invert #{aes}:  scale #{scale.toString()}"
      if newTable.contains aes
        f = (v) -> if v? then scale.invert(v) else null
        newTable.map f, aes
      else
        console.log "gg.ScaleSet.invert notfound: #{aes}"

    newTable

  labelFor: -> null



# transforms data -> pixel/aesthetic values
class gg.ScalesApply extends gg.XForm
  constructor: (@layer, @spec) ->
    super @layer.g, @spec
    @parseSpec()

  parseSpec: ->
    super
    @aess = findGoodAttr @spec, ['aess'], []
    @posMapping = @spec.posMapping or {}

  compute: (table, env) ->
    scales = @scales table, env
    aess = _.compact(_.union scales.aesthetics(), @aess)
    @log ":aesthetics: #{aess}"
    table = scales.apply table, aess, @posMapping
    table


# transforms pixel -> data
class gg.ScalesInvert extends gg.XForm
  constructor: (@layer, @spec) ->
    super @layer.g, @spec
    @parseSpec()

  parseSpec: ->
    super
    @aess = findGoodAttr @spec, ['aess'], []
    @posMapping = @spec.posMapping or {}

  compute: (table, env) ->
    scales = @scales table, env
    aess = _.compact(_.union scales.aesthetics(), @aess)
    @log ":aesthetics: #{aess}"
    table = scales.invert table, aess, @posMapping
    table




