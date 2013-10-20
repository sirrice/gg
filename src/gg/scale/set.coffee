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
    for s in @scalesList()
      ret.set s.clone()
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


  exclude: (aesthetics) ->
    _.each aesthetics, (aes) =>
      if aes of @scales
        delete @scales[aes]
    @

  aesthetics: ->
    keys = _.keys @scales
    _.uniq _.compact _.flatten keys

  contains: (aes, type=null, posMapping={}) ->
    aes = posMapping[aes] or aes
    if aes of @scales
      unless type?
        return true
      unless _.size(@scales[aes]) > 0
        unless type is gg.data.Schema.unknown
          return true
      if type of @scales[aes]
        return true
    false
  has: (aes, type, posMapping) -> @contains aes, type, posMapping

  types: (aes, posMapping={}) ->
    aes = posMapping[aes] or aes
    if aes of @scales
      types = _.keys(@scales[aes])
      types = _.map types, (v) -> parseInt(v)
      types.filter (t) -> _.isNumber(t) and not _.isNaN(t)
      types
    else
      []

  userdefinedType: (aes) ->
    @factory.type aes

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
  get: (aes, types, posMapping={}) ->
    unless types?
      throw Error("type cannot be null: #{aes}")
    types = _.reject _.flatten([types]), _.isNull
    unless types.length > 0
      throw Error("type cannot be empty: #{aes}")


    aes = 'x' if aes in gg.scale.Scale.xs
    aes = 'y' if aes in gg.scale.Scale.ys
    aes = posMapping[aes] or aes
    @scales[aes] = {} unless aes of @scales

    type = null
    for t in types
      if @has aes, t
        type = t
        break
    type ?= _.last types


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
      udt = @userdefinedType aes
      if (udt != type) and (udt != gg.data.Schema.unknown) and _.size(@scales[aes]) > 0
        @log.warn "downcasting requested scale type from #{type} -> #{@userdefinedType aes} because user defined"
        _.values(@scales[aes])[0]
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

  # for scales in this set, merge any that can be found
  # in scales argument
  #
  # @param scales a gg.scale.Set or gg.scale.MergedSet object
  #
  merge: (scales) ->
    for col, colscales of @scales
      continue if col is 'text'

      for type, s of colscales
        continue unless scales.contains(col, type, s.constructor.name)
        continue if _.isType s, gg.scale.Identity

        other = scales.get col, type, s.constructor.name
        oldd = s.domain()
        s.mergeDomain other.domain()
        @log "merge: #{s.domainUpdated} #{col}.#{s.id}:#{type}: #{oldd} + #{other.domain()} -> #{s.domain()}"

    @

  useScales: (table, posMapping={}, f) ->
    for col in table.cols()
      if @contains col, null, posMapping
        truecol = posMapping[col] or col
        tabletype = table.schema.type col
        unknown = gg.data.Schema.unknown
        scale = @scale col, [tabletype, unknown], posMapping
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
      mapping = [] 
      mapping.push [
        col
        ((v) -> scale.scale v)
        gg.data.Schema.unknown
      ]
      if table.has col
        table = gg.data.Transform.mapCols table, mapping
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
      g = (row) -> 
        v = row.get col
        checks = [_.isNaN, _.isUndefined, _.isNull]
        if not _.any(checks, (f) -> f(v))
          scale.valid v
        else
          true
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
      mapping = [
        [
          col
          (v) -> if v? then scale.invert(v) else null
          gg.data.Schema.unknown
        ]
      ]

      origDomain = scale.defaultDomain table.getColumn(col)
      newDomain = null
      if table.has col
        table = gg.data.Transform.mapCols table, mapping
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


