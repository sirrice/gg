#<< gg/scale/factory
#

#
#
# Manage a graphic/pane/layer's set of scales
# a Wrapper around {aes -> {type -> scale} } + utility functions
#
# lazily instantiates scale objects as they are requests.
# uses internal scalesFactory for creation
#
class gg.scale.Set
  @ggpackage = 'gg.scale.Set'

  constructor: (@factory=null) ->
    @factory ?= new gg.scale.Factory
    @scales = {}
    @spec = {}
    @id = gg.scale.Set::_id
    gg.scale.Set::_id += 1

    @log = gg.util.Log.logger @constructor.ggpackage, "ScaleSet-#{@id}"
  _id: 0

  clone: () ->
    ret = new gg.scale.Set @factory
    ret.spec = _.clone @spec
    ret.merge @, yes
    ret

  toJSON: ->
    factory: _.toJSON @factory
    scales: _.toJSON @scales
    spec: _.toJSON @spec

  @fromJSON: (json) ->
    factory = _.fromJSON json.factory
    set = new gg.scale.Set factory
    set.scales = _.fromJSON json.scales
    set.spec =_.fromJSON json.spec
    set

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
    if aes of @scales
      types = _.map @scales[aes], (v, k) -> parseInt k
      types.filter (t) -> _.isNumber t and not _.isNaN t
      types
    else
      []

  # @param type.  the only time type should be null is when
  #        retrieving the "master" scale to render for guides
  scale: (aesOrScale, type=null, posMapping={}) ->
    if _.isString aesOrScale
      @get aesOrScale, type, posMapping
    else if aesOrScale?
      @set aesOrScale

  set: (scale) ->
    if scale.type is gg.data.Schema.unknown
      throw Error("Storing scale type unknown: #{scale.toString()}")
    aes = scale.aes
    @scales[aes] = {} unless aes of @scales
    @scales[aes][scale.type] = scale
    scale


  # Combines fetching and creating scales
  #
  get: (aes, type, posMapping={}) ->
    unless type?
      throw Error("type cannot be null anymore: #{aes}")

    aes = 'x' if aes in gg.scale.Scale.xs
    aes = 'y' if aes in gg.scale.Scale.ys
    aes = posMapping[aes] or aes
    @scales[aes] = {} unless aes of @scales

    if type is gg.data.Schema.unknown
      vals = _.values @scales[aes]
      if vals.length > 0
        vals[0]
      else
        @log "get: creating new scale #{aes} #{type}"
        # in the future, return default scale?
        @set @factory.scale aes, type
        #throw Error("gg.ScaleSet.get(#{aes}) doesn't have any scales")

    else
      unless type of @scales[aes]
        @scales[aes][type] = @factory.scale aes, type
      @scales[aes][type]


  scalesList: ->
    _.flatten _.map(@scales, (map, aes) -> _.values(map))


  resetDomain: ->
    _.each @scalesList(), (scale) =>
      @log "resetDomain #{scale.toString()}"
      scale.resetDomain()



  # @param scaleSets array of gg.scale.Set objects
  # @return a single gg.scale.Set object that merges the inputs
  @merge: (scaleSets) ->
    return null if scaleSets.length is 0

    ret = scaleSets[0].clone()
    _.each _.rest(scaleSets), (scales) -> ret.merge scales, true
    ret

  # @param scales a gg.scale.Set object
  # @param insert should we add new aesthetics that exist in scales argument?
  # merges domains of argument scales with self
  # updates in place
  #
  merge: (scales, insert=true) ->
    _.each scales.aesthetics(), (aes) =>
      if aes is 'text'
          return

      _.each scales.scales[aes], (scale, type) =>
        # XXX: when should this ever be skipped?
        #return unless scale.domainUpdated and scale.rangeUpdated

        if @contains aes, type
          mys = @scale aes, type
          oldd = mys.domain()
          mys.mergeDomain scale.domain()
          @log "merge: #{mys.domainUpdated} #{aes}.#{mys.id}:#{type}: #{oldd} + #{scale.domain()} -> #{mys.domain()}"

        else if insert
          copy = scale.clone()
          @log "merge: #{aes}.#{copy.id}:#{type}: clone: #{copy.domainUpdated}/#{scale.domainUpdated}: #{copy.toString()}"
          @scale copy, type

        else
          @log "merge notfound + dropping scale: #{scale.toString()}"

    @


  useScales: (table, posMapping={}, f) ->
    for col in table.cols()
      if @contains (posMapping[col] or col)
        scale = @scale col, gg.data.Schema.unknown, posMapping
      else
        tabletype = table.schema.type col
        @log "scaleset doesn't contain #{col} creating using type #{tabletype}"
        scale = @scale col, tabletype, posMapping
      @log scale.toString()

      table = f table, scale, col

    table


  # each aesthetic will be trained
  # multiple layers may use same aesthetics so need to cope with
  # overlaps
  # @param posMapping maps table attr to aesthetic with scale
  #        attr -> aes
  #        attr -> [aes, type]
  train: (table, posMapping={}) ->
    f = (table, scale, col) =>
      unless table.has col
        @log "col #{col} not in table"
        return table

      if _.isSubclass scale, gg.scale.Identity
        @log "scale is identity."
        return table

      colData = table.getColumn col
      unless colData?
        throw Error("Set.train: attr #{col} does not exist in table")

      colData = colData.filter _.isValid
      if colData.length < table.nrows()
        @log "filtered out #{table.nrows()-colData.length} col values"

      @log "col #{col} has #{colData.length} elements"
      if colData? and colData.length > 0
        newDomain = scale.defaultDomain colData
        oldDomain = scale.domain()
        minval = _.mmin [oldDomain[0],newDomain[0]]
        maxval = _.mmax [oldDomain[1], newDomain[1]]
        @log "domains: #{scale.toString()} #{oldDomain} + #{newDomain} = [#{minval}, #{maxval}]"
        throw Error() unless newDomain?
        throw Error() if _.isNaN newDomain[0]

        scale.mergeDomain newDomain

        if scale.type is gg.data.Schema.numeric
          @log "train: #{col}(#{scale.id})\t#{oldDomain} merged with #{newDomain} to #{scale.domain()}"
        else
          @log "train: #{col}(#{scale.id})\t#{scale}"

      table

    @useScales table, posMapping, f
    @

  # @param posMapping maps aesthetic names to the scale that
  #        should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  apply: (table,  posMapping={}) ->
    f = (table, scale, col) =>
      str = scale.toString()
      mapping = {}
      mapping[col] = (row) -> scale.scale row.get(col)
      if table.has col
        table = gg.data.Transform.transform table, mapping
      @log "apply: #{col}(#{scale.id}):\t#{str}\t#{table.nrows()} rows"
      table


    @log "apply: table has #{table.nrows()} rows"
    table = @useScales table, posMapping, f
    table

  # @param posMapping maps aesthetic names to the scale that
  #        should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  filter: (table, posMapping={}) ->
    filterFuncs = []
    f = (table, scale, col) =>
      g = (row) -> scale.valid row.get(col)
      g.col = col
      @log "filter: #{scale.toString()}"
      filterFuncs.push g if table.has col
      table

    @useScales table, posMapping, f

    nRejected = 0
    g = (row) =>
      for f in filterFuncs
        unless f(row)
          nRejected += 1
          @log "Row rejected on attr #{f.col} w val: #{row.get f.col}"
          return no
      yes

    table = gg.data.Transform.filter table, g
    @log "filter: removed #{nRejected}.  #{table.nrows()} rows left"
    table


  # @param posMapping maps aesthetic names to the scale
  #        that should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  # @param {gg.Table} table
  # @return inverted table
  invert: (table, posMapping={}) ->
    f = (table, scale, col) =>
      mapping = {}
      mapping[col] = (row) ->
        v = row.get col
        if v? then scale.invert(v) else null

      origDomain = scale.defaultDomain table.getColumn(col)
      newDomain = null
      if table.has col
        table = gg.data.Transform.transform table, mapping
        newDomain = scale.defaultDomain table.getColumn(col)

      if scale.domain()?
        @log "invert: #{col}(#{scale.id};#{scale.domain()}):\t#{origDomain} --> #{newDomain}"
      table

    table = @useScales table, posMapping, f
    table

  labelFor: -> null

  toString: (prefix="") ->
    arr = _.flatten _.map @scales, (map, col) =>
      _.map map, (scale, type) => "#{prefix}#{col}: #{scale.toString()}"
    arr.join('\n')


