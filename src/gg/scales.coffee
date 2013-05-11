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


    @prestats = @trainDataNode
      name: "scales-prestats"
    @postgeommap = @trainDataNode
      name: "scales-postgeommap"
    @trainpixel = @trainPixelNode
      name: "scales-pixel"


    @parseSpec()


  # XXX: assumes layers have been created already
  parseSpec: ->
    @scalesConfig = gg.ScaleConfig.fromSpec @spec

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
    @_trainPixelNode = new gg.wf.Barrier
      name: spec.name
      f: (args...) => @trainOnPixels args...,spec
    @_trainPixelNode


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

      console.log "Scales.trainOnData table:      #{t.colNames()}"
      console.log "Scales.trainOnData scaleSet.id #{scales.id}"
      # if scales factory does'nt define scale type, then
      # use datatype!


      scales.train t, null, spec.posMapping

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
    infos = _.map _.zip(tables, envs), ([t,e]) => @paneInfo t, e

    originalSchemas = _.map tables, (t) -> t.schema

    allAessTypes = []
    inverteds = _.map _.zip(tables, infos), ([t,info]) =>
      scales = @scales info.facetX, info.facetY, info.layer
      posMapping = @posMapping info.layer
      console.log scales.toString()
      console.log t.schema.toString()

      aessTypes = {}
      # only table columns that have a corresponding
      # ordinal scale are allowed
      aessTypes = _.map t.colNames(), (aes) ->
        _.map scales.types(aes, posMapping), (type) ->
          unless type is gg.Schema.ordinal
            if t.contains aes, type
              {aes: aes, type: type}
      aessTypes = _.compact _.flatten aessTypes
      allAessTypes.push aessTypes


      console.log "Scales.trainOnPixels posMapping: #{JSON.stringify posMapping}"
      console.log "Scales.trainOnPixels table:      #{t.colNames()}"
      console.log "Scales.trainOnPixels scaleSet.id (#{scales.id})"
      console.log "Scales.trainOnPixels inverted aes #{JSON.stringify aessTypes}"


      inverted = scales.invert t, aessTypes, posMapping
      scales.resetDomain()
      scales.train inverted, aessTypes, posMapping
      console.log scales.toString()
      inverted

    #console.log JSON.stringify inverteds[0].raw()


    apply = ([t,info, aessTypes,origSchema]) =>
      scales = @scales info.facetX, info.facetY, info.layer
      posMapping = @posMapping info.layer
      console.log "Scales.trainOnPixels reapplying scales: #{JSON.stringify aessTypes}"

      console.log "Scales.trainOnpixels pre-Schema: #{t.schema.toString()}"
      t = scales.apply t, aessTypes, posMapping
      t.schema = origSchema
      console.log "Scales.trainOnpixels postSchema: #{t.schema.toString()}"
      t

    args = _.zip(inverteds, infos, allAessTypes, originalSchemas)
    newTables = _.map args, apply

    @g.facets.trainScales()
    newTables

  trainForFacets: (tables, envs, node) ->
    @g.facets.trainScales()


  layer: (layerIdx) -> @g.layers.getLayer layerIdx


  posMapping: (layerIdx) -> @layer(layerIdx).geom.posMapping()

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
    console.log "gg.ScaleConfig new\n\t#{JSON.stringify @defaults}\n\t#{JSON.stringify @layerDefaults}"

  @fromSpec: (spec, layerSpecs={}) ->

    console.log "gg.ScaleConfig.spec: #{JSON.stringify spec}"
    console.log "gg.ScaleConfig.lSpec: #{JSON.stringify layerSpecs}"

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
        scaleSpec = {type: scaleSpec} if _.isString scaleSpec
        scaleSpec = _.clone scaleSpec
        scaleSpec.aes = aes
        scale = gg.Scale.fromSpec scaleSpec
        ret[aes] = scale
    ret

  addLayerDefaults: (layer) ->
    layerIdx = layer.layerIdx
    layerSpec = layer.spec
    scalesSpec = layerSpec.scales
    layerConfig = gg.ScaleConfig.loadSpec scalesSpec
    @layerDefaults[layerIdx] = layerConfig
    console.log "gg.ScaleConfig.addLayer #{layerConfig}"



  factoryFor: (layerIdx) ->
    spec = _.clone @defaults
    lspec = @layerDefaults[layerIdx] or {}
    _.extend spec, lspec
    gg.ScaleFactory.fromSpec spec

  scale: (aes, type) -> @factoryFor().scale(aes, type)
  scales: (layerIdx) -> new gg.ScalesSet @factoryFor(layerIdx)


class gg.ScaleFactory
  constructor: (@defaults) ->
    console.log "gg.ScaleFactory new:\n#{@toString()}"

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
  toString: ->
    arr = _.map @defaults, (scale, aes) ->
      "\t#{aes} -> #{scale.toString()}"
    arr.join("\n")









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

  types: (aes, posMapping={}) ->
    aes = posMapping[aes] or aes
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
    _.each _.rest(scalesArr), (scales) -> ret.merge scales, true
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
          ###
          else if @contains aes
            console.log "gg.ScalesSet.merge: unmatched type #{aes} #{type}\t#{scale.toString()}"
            mys = @scale aes#, gg.Schema.unknown
            @scale(aes).mergeDomain scale.domain()
          ###
        else if insert
          console.log "inserting clone: #{scale.clone().toString()}"
          @scale scale.clone(), type
        else
          console.log "gg.ScalesSet.merge #{insert}: dropping scale! #{scale}"

    @

  useScales: (table, aessTypes=null, posMapping={}, f) ->
    unless aessTypes?
      aessTypes = _.compact _.map(table.schema.attrs(), (attr) ->
        {aes: attr, type: table.schema.type(attr) })

    if aessTypes.length > 0 and not _.isObject(aessTypes[0])
      aessTypes = _.map aessTypes, (aes) ->
        typeAes = posMapping[aes] if aes of posMapping
        console.log "useScales aes: #{aes} ; #{table.schema.type typeAes}"
        {aes: aes, type: table.schema.type typeAes}


    #console.log "gg.ScaleSet.useScales: \n\t#{JSON.stringify aessTypes}\n\t#{table.colNames()}"
    _.each aessTypes, (at) =>
      aes = at.aes
      type = at.type
      return unless table.contains aes, type
      scale = @scale(aes, type, posMapping)
      f table, scale, aes

    table


  # each aesthetic will be trained
  # multiple layers may use same aesthetics so need to cope with
  # overlaps
  # @param posMapping maps table attr to aesthetic with scale
  #        attr -> aes
  #        attr -> [aes, type]
  train: (table, aessTypes=null, posMapping={}) ->
    f = (table, scale, aes) =>
      # XXX: perform type checking.  Just assume all
      #      continuous for now
      col = table.getColumn(aes)
      col = col.filter (v) -> not (_.isNaN(v) or _.isNull(v) or _.isUndefined(v))
      scale.mergeDomain scale.defaultDomain col if col?
      console.log col if aes == 'stroke'
      console.log "scalesSet.train: #{aes}\t#{scale}"

    @useScales table, aessTypes, posMapping, f
    @

  # @param posMapping maps aesthetic names to the scale that
  #        should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  apply: (table, aessTypes=null, posMapping={}) ->
    f = (table, scale, aes) =>
      str = scale.toString()
      console.log "gg.ScaleSet.apply #{aes}:  scale #{str}"
      g = (v) -> scale.scale v
      table.map g, aes if table.contains aes
      #console.log "gg.ScaleSet.apply #{table.getColumn(aes)[0..10]}"

    table = table.clone()
    @useScales table, aessTypes, posMapping, f
    #console.log "reloading schema"
    #table.reloadSchema()
    table

  # @param posMapping maps aesthetic names to the scale
  #        that should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  # @param {gg.Table} table
  invert: (table, aessTypes=null, posMapping={}) ->
    f = (table, scale, aes) =>
      str = scale.toString()
      console.log "gg.ScaleSet.invert #{aes}:  scale #{str}"
      g = (v) -> if v? then  scale.invert(v) else null
      table.map g, aes if table.contains aes
      #console.log "gg.ScaleSet.invert #{table.getColumn(aes)[0..10]}"

    table = table.clone()
    @useScales table, aessTypes, posMapping, f
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
    table = scales.apply table, null, @posMapping
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
    table = scales.invert table, null, @posMapping
    table




