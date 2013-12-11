#<< gg/scale/factory
#

# Scales specify how table columns should be
# interpreted.
#
# Any given layer/facet should have a single scale
# This manages a set of scales { aes -> scale } + utility functions
#
# lazily instantiates scale objects as they are requests.
# uses internal scalesFactory for creation
#
class gg.scale.Set
  @ggpackage = 'gg.scale.Set'

  constructor: (@factory=null) ->
    @factory ?= new gg.scale.Factory
    @scales = {}
    @id = gg.scale.Set::_id
    gg.scale.Set::_id += 1

    @log = gg.util.Log.logger @constructor.ggpackage, "ScaleSet-#{@id}"
  _id: 0

  clone: () ->
    ret = new gg.scale.Set @factory
    for s in @scalesList()
      ret.set s.clone()
    ret

  toJSON: ->
    factory: _.toJSON @factory
    scales: _.toJSON @scales

  @fromJSON: (json) ->
    factory = _.fromJSON json.factory
    set = new gg.scale.Set factory
    set.scales = _.fromJSON json.scales
    set.spec =_.fromJSON json.spec
    set


  cols: -> _.keys @scales

  all: -> _.values @scales

  contains: (aes, type=null, posMapping={}) ->
    aes = posMapping[aes] or aes
    aes of @scales
  has: (aes, type, posMapping) -> @contains aes, type, posMapping

  type: (aes, posMapping={}) ->
    aes = posMapping[aes] or aes
    if aes of @scales
      @scales[aes].type
    else
      []

  userdefinedType: (aes) -> @factory.type aes


  # @param type.  the only time type should be null is when
  #        retrieving the "master" scale to render for guides
  scale: (aesOrScale, type, posMapping={}) ->
    if _.isString aesOrScale
      @get aesOrScale, type, posMapping
    else if aesOrScale?
      @set aesOrScale

  set: (scale) ->
    if scale.type is data.Schema.unknown and not _.isType(scale, gg.scale.Identity)
      throw Error("Storing scale type unknown: #{scale.toString()}")
    @scales[scale.aes] = scale
    scale


  # Combines fetching and creating scales
  #
  get: (aes, type, posMapping={}) ->
    aes = 'x' if aes in gg.scale.Scale.xs
    aes = 'y' if aes in gg.scale.Scale.ys
    aes = posMapping[aes] or aes

    unless aes of @scales
      udt = @userdefinedType aes
      type = udt if udt? and udt != data.Schema.unknown
      @scales[aes] = @factory.scale aes, type
    @scales[aes]

  scalesList: -> _.values @scales

  # for scales in this set, merge any that can be found
  # in scales argument
  #
  # @param scales a gg.scale.Set or gg.scale.MergedSet object
  #
  merge: (scales) ->
    for col, s of @scales
      continue if col is 'text'
      continue unless scales.contains col, s.type, s.constructor.name
      continue if _.isType s, gg.scale.Identity

      other = scales.get col, s.type, s.constructor.name
      d = s.domain()
      s.mergeDomain other.domain()
      @log "merge: #{s.domainUpdated} #{col}.#{s.id}:#{s.type}: #{d} + #{other.domain()} -> #{s.domain()}"

    @





  #############################################################################
  #
  # The following are methods to _apply_ a scale set to a data table
  #
  #############################################################################



  # general framework.  for each column in a table, get or create its scale and call 
  # a user defined function
  useScales: (table, posMapping={}, f) ->
    for col in table.cols()
      tabletype = table.schema.type col
      scale = @scale col, tabletype, posMapping
      table = f table, scale, col
    table


  # each aesthetic will be trained
  # multiple layers may use same aesthetics so need to cope with
  # overlaps
  # @param posMapping maps table attr to aesthetic with scale
  #        attr -> aes
  #        attr -> [aes, type]
  train: (table, posMapping={}) ->
    colDatas = table.all table.cols()
    for col, idx in table.cols()
      tabletype = table.schema.type col
      scale = @scale col, tabletype, posMapping

      if _.isType scale, gg.scale.Identity
        @log "scale is identity."
        continue

      colData = colDatas[idx]
      nrows = colData.length
      colData = colData.filter _.isValid
      if colData.length < nrows
        @log "filtered out #{table.nrows()-colData.length} col values"

      @log "col #{col} has #{colData.length} elements"
      if colData? and colData.length > 0
        newDomain = scale.defaultDomain colData
        oldDomain = scale.domain()
        minval = d3.min [oldDomain[0],newDomain[0]]
        maxval = d3.max [oldDomain[1], newDomain[1]]
        @log "domains: #{scale.toString()} #{oldDomain} + #{newDomain} = [#{minval}, #{maxval}]"
        unless newDomain?
          throw Error("set.train #{col} no new domain. old: #{scale.toString()}") 
        if _.isNaN newDomain[0]
          throw Error("set.train #{col} newDomain has NaN: #{newDomain}.  old: #{scale.toString()}") 

        scale.mergeDomain newDomain

        if scale.type is data.Schema.numeric
          @log "train: #{col}(#{scale.id})\t#{oldDomain} merged with #{newDomain} to #{scale.domain()}"
        else
          @log "train: #{col}(#{scale.id})\t#{scale}"

    @

  # @param posMapping maps aesthetic names to the scale that
  #        should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  apply: (table,  posMapping={}) ->
    mappings = []
    f = (table, scale, col) =>
      return table unless table.has col
      mapping = 
        alias: col
        f: (v) -> 
          if scale.valid(v) 
            scale.scale v
          else
            v
        cols: col
      mappings.push mapping

      str = scale.toString()
      @log "apply: #{col}(#{scale.id}):\t#{str}"
      table

    table = @useScales table, posMapping, f
    table = table.project mappings, yes
    table

  # @param posMapping maps aesthetic names to the scale that
  #        should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  filter: (table, posMapping={}) ->
    filterFuncs = []
    f = (table, scale, col) =>
      return table if _.isType scale, gg.scale.Identity
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

    table = table.filter g
    @log "filter: removed #{nRejected}.  #{table.nrows()} rows left"
    table


  # @param posMapping maps aesthetic names to the scale
  #        that should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  # @param {gg.Table} table
  # @return inverted table
  invert: (table, posMapping={}) ->
    f = (table, scale, col) =>
      return table unless table.has col
      mapping = [
        {
          alias: col
          cols: col
          f: (v) -> if v? then scale.invert(v) else null
          type: data.Schema.unknown
        }
      ]

      table = table.project mapping , yes
      table

    table = @useScales table, posMapping, f
    table

  labelFor: -> null

  toString: (prefix="") ->
    arr = _.map @scales, (s, col) -> "#{prefix}#{col}: #{s.toString()}"
    arr.join('\n')


