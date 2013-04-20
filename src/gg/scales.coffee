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

  constructor: (@g, @spec) ->
    super
    @scalesConfig = null
    @mappings = {}     # facetX -> facetY -> layerIdx -> scalesSet
    @scalesList = []  # list of the scalesSet objects

    @parseSpec()


  parseSpec: ->
    # setup the scales factory
    # XXX: we probably want different scale factories per layer
    @scalesConfig = gg.ScaleConfig.fromSpec @spec
    # scan through @g.layers for more scales specs

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
    infos = _.map _.zip(tables, envs), ([t,e]) => @paneInfo t, e

    inverteds = _.map _.zip(tables, infos), ([t,info]) =>
      scales = @scales info.facetX, info.facetY, info.layer
      #aess = @aesthetics info.layer
      aess = t.colNames()

      console.log "Scales.trainOnPixels table:      #{t.colNames()}"
      console.log "Scales.trainOnPixels scaleSet.id (#{scales.id})"
      console.log "Scales.trainOnPixels inverted aes #{aess}"


      fillScale = scales.get('fill', gg.Schema.ordinal)
      console.log "PreInvert: #{t.getColumn("fill")}"
      console.log "TheScales: #{fillScale}"
      console.log "FillType:  #{t.schema.type 'fill'}"
      console.log "Invert something: #{fillScale.invert "#aec7e80"}"
      inverted = scales.invert t, aess, spec.posMapping
      console.log "Inverted: #{inverted.getColumn("fill")}"
      scales.resetDomain()
      scales.train inverted, aess, spec.posMapping
      inverted

    newTables = _.map _.zip(inverteds, infos), ([t,info]) =>
      scales = @scales info.facetX, info.facetY, info.layer
      aess = t.colNames()

      scales.apply t, aess, spec.posMapping

    @g.facets.trainScales()
    newTables

  trainForFacets: (tables, envs, node) ->
    @g.facets.trainScales()


  layer: (layerIdx) -> @g.layers.getLayer layerIdx

  # XXX: layer aesthetics should differentiate between
  #      pre and post stats aesthetic mappings!
  aesthetics: (layerIdx) ->
    throw Error("gg.Scales.aesthetics not implemented")
    scalesAess = []#@scalesConfig.aesthetics()
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
        #aess = @aesthetics layerIdx
        aess = []
        # XXX: support other factories for per-layer scales
        newScalesSet = @scalesConfig.scales layerIdx
        map[layerIdx] = newScalesSet
        @scalesList.push newScalesSet
      map[layerIdx]
    else
      _.values map



# the scale config can be used as a scale factory with
# just the default scales
#
# also creates layer specific scale factories
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
class gg.ScaleConfig

  # @param defaults:        aes -> scale
  # @param layerDefaults:   layer -> {aes -> scale}
  constructor: (@defaults, @layerDefaults)  ->

  @fromSpec: (spec, layerSpecs={}) ->
    config = new gg.ScaleConfig

    # load graphic defaults
    defaults = gg.ScaleConfig.loadSpec spec

    # load layer defaults
    layerDefaults = {}
    _.each layerSpecs, (layerSpec, layerIdx) =>
      scalesSpec = layerSpec.scales
      layerConfig = gg.ScaleConfig.loadSpec scalesSpec
      layerDefaults[layerIdx] = layerConfig

    new gg.ScaleConfig defaults, layerDefaults

  @loadSpec: (spec) ->
    ret = {}
    if spec?
      _.each spec, (scaleSpec, aes) ->
        scaleSpec = _.clone scaleSpec
        scaleSpec.aes = aes
        scale = gg.Scale.fromSpec scaleSpec
        ret[aes] = scale
    ret

  factoryFor: (layerIdx) ->
    spec = _.clone @defaults
    lspec = @layerDefaults[layerIdx] or {}
    _.extend spec, lspec
    gg.ScaleFactory.fromSpec spec

  scale: (aes, type) -> @factoryFor().scale(aes, type)
  scales: (layerIdx) -> new gg.ScalesSet @factoryFor(layerIdx)


class gg.ScaleFactory
  constructor: (@defaults) ->

  @fromSpec: (spec) ->
    sf = new gg.ScaleFactory spec
    sf

  scale: (aes, type) ->
    unless aes?
      throw Error()
    unless type?
      throw Error()

    scale =
      if aes of @defaults
        @defaults[aes].clone()
      else
        gg.Scale.defaultFor aes, type

    scale

  scales: (layerIdx) -> new gg.ScalesSet @








#
#
# Manage a graphic/pane/layer's set of scales
# a Wrapper around {aes -> {type -> scale} } + utility functions
#
# lazily instantiates scale objects as they are requests.
# uses internal scalesFactory for creation
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
    _.uniq _.compact _.flatten keys

  contains: (aes, type=null) ->
    aes of @scales and (not type or type of @scales[aes])

  types: (aes) ->
    if aes of @scales then _.keys @scales[aes] else []

  # @param type.  the only time type should be null is when
  #        retrieving the "master" scale to render for guides
  scale: (aesOrScale, type=null, posMapping={}) ->
    if _.isString aesOrScale
      @get aesOrScale, type, posMapping
    else if aesOrScale?
      @set aesOrScale

  set: (scale) ->
    aes = scale.aes
    @scales[aes] = {} unless aes of @scales
    @scales[aes][scale.type] = scale
    scale


  get: (aes, type, posMapping={}) ->
    unless type?
      throw Error("type cannot be null anymore: #{aes}")

    aes = 'x' if aes in gg.Scale.xs
    aes = 'y' if aes in gg.Scale.ys
    aes = posMapping[aes] or aes
    @scales[aes] = {} unless aes of @scales

    if type is gg.Schema.unknown
      if type of @scales[aes]
        throw Error("#{aes}: stored scale type shouldn't be unknown")

      vals = _.values @scales[aes]
      if vals.length > 0
        vals[0]
      else
        console.log "creating scaleset.get #{aes} #{type}"
        # in the future, return default scale?
        @set @factory.scale aes
        #throw Error("gg.ScaleSet.get(#{aes}) doesn't have any scales")

    else
      unless type of @scales[aes]
        @scales[aes][type] = @factory.scale aes, type
      @scales[aes][type]


  scalesList: ->
    _.flatten _.map(@scales, (map, aes) -> _.values(map))


  resetDomain: ->
    _.each @scalesList(), (scale) -> scale.resetDomain()



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
    aess = table.colNames() unless aess?
    aess = _.uniq _.keys @scales unless aess?
    console.log "gg.ScalesSet.train: #{aess}"

    _.each aess, (aes) =>
      return unless table.contains aes
      type = table.schema.type(aes)
      scale = @scale(aes, type, posMapping)


      unless table.contains aes
        attrs = table.colNames()
        console.log "scalesSet.train: #{aes} not in table: #{attrs}"


      # XXX: perform type checking.  Just assume all
      #      continuous for now
      col = table.getColumn(aes)
      scale.mergeDomain scale.defaultDomain col if col?
      console.log "scalesSet.train: #{aes}\t#{scale}"

    @


  # @param posMapping maps aesthetic names to the scale that
  #        should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  apply: (table, aess=null, posMapping={}) ->
    aess = table.colNames() unless aess?
    aess = @aesthetics() unless aess?

    table = table.clone()
    console.log "gg.ScaleSet.apply: #{aess}\t#{table.colNames()}"
    _.each aess, (aes) =>
      return unless table.contains aes
      type = table.schema.type(aes)
      scale = @scale(aes, type, posMapping)
      f = (v) -> scale.scale v, type
      table.map f, aes if table.contains aes

    table

  # @param posMapping maps aesthetic names to the scale that should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  # @param {gg.Table} table
  invert: (table, aess=null, posMapping={}) ->
    aess = table.colNames() unless aess?
    aess = @aesthetics() unless aess?

    table = table.clone()
    console.log "gg.ScaleSet.invert #{aess}"
    _.each aess, (aes) =>
      return unless table.contains aes
      type = table.schema.type(aes)
      scale = @scale(aes, type, posMapping)

      str = scale.toString()
      #console.log "gg.ScaleSet.invert #{aes}:  scale #{str}"

      f = (v) ->
        if aes == 'fill'
          console.log "\tinvert fill #{type}: #{v} -> #{scale.invert v}\t#{scale.toString()}"
        if v?
          scale.invert(v)
        else
          null
      table.map f, aes if table.contains aes

    table

  labelFor: -> null

  toString: ->
    arr = _.flatten _.map @scales, (map, aes) =>
      _.map map, (scale, type) => scale.toString()
    arr.join('\n')



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




