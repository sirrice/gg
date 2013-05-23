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
  constructor: (@factory) ->
    @scales = {}
    @spec = {}
    @id = gg.scale.Set::_id
    gg.scale.Set::_id += 1

    @log = gg.util.Log.logger "ScaleSet-#{@id}", gg.util.Log.DEBUG
  _id: 0

  clone: () ->
    ret = new gg.scale.Set @factory
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

    aes = 'x' if aes in gg.scale.Scale.xs
    aes = 'y' if aes in gg.scale.Scale.ys
    aes = posMapping[aes] or aes
    @scales[aes] = {} unless aes of @scales

    if type is gg.data.Schema.unknown
      if type of @scales[aes]
        throw Error("#{aes}: stored scale type shouldn't be unknown")

      vals = _.values @scales[aes]
      if vals.length > 0
        vals[0]
      else
        @log "creating scaleset.get #{aes} #{type}"
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
    _.each @scalesList(), (scale) =>
      @log "resetDomain #{scale.toString()}"
      scale.resetDomain()



  # @param scalesArr array of gg.scale.Set objects
  # @return a single gg.scale.Set object that merges the inputs
  @merge: (scalesArr) ->
    return null if scalesArr.length is 0

    ret = scalesArr[0].clone()
    _.each _.rest(scalesArr), (scales) -> ret.merge scales, true
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
        return unless scale.domainUpdated

        if @contains aes, type
          mys = @scale aes, type
          @scale(aes, type).mergeDomain scale.domain()
          ###
          else if @contains aes
            @log "gg.scale.Set.merge: unmatched type #{aes} #{type}\t#{scale.toString()}"
            mys = @scale aes#, gg.Schema.unknown
            @scale(aes).mergeDomain scale.domain()
          ###
        else if insert
          copy = scale.clone()
          @log "merge: insertclone: #{copy.toString()}"
          @scale copy, type
        else
          @log "merge notfound + dropping scale: #{scale.toString()}"

    @

  useScales: (table, aessTypes=null, posMapping={}, f) ->
    unless aessTypes?
      aessTypes = _.compact _.map(table.schema.attrs(), (attr) ->
        {aes: attr, type: table.schema.type(attr) })

    if aessTypes.length > 0 and not _.isObject(aessTypes[0])
      aessTypes = _.map aessTypes, (aes) =>
        # XXX: it's not clear why this is the correct logic
        #      either:
        #      1) pick posMapped aes type from table
        if aes of posMapping and table.contains posMapping[aes]
          typeAes = posMapping[aes]
          @log "useScales: aes: #{aes}(#{scale.id})\ttype: #{table.schema.type typeAes}"
          {aes: aes, type: table.schema.type typeAes}
        else
        #      2) pick aes type from table
          {aes: aes, type: table.schema.type aes}

    _.each aessTypes, (at) =>
      aes = at.aes
      type = at.type
      return unless table.contains aes, type
      # @log "useScales: fetch #{aes}\t#{type}\t#{posMapping[aes]}"
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
      return unless table.contains aes
      col = table.getColumn(aes)
      col = col.filter (v) -> not (_.isNaN(v) or _.isNull(v) or _.isUndefined(v))

      if col?
        newDomain = scale.defaultDomain col
        oldDomain = scale.domain()

        scale.mergeDomain newDomain

        if scale.type is gg.data.Schema.numeric
          @log "train: #{aes}(#{scale.id})\t#{oldDomain} merged with #{newDomain} to #{scale.domain()}"
        else
          @log "train: #{aes}(#{scale.id})\t#{scale}"

    @useScales table, aessTypes, posMapping, f
    @

  # @param posMapping maps aesthetic names to the scale that
  #        should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  apply: (table, aessTypes=null, posMapping={}) ->
    f = (table, scale, aes) =>
      str = scale.toString()
      g = (v) -> scale.scale v
      table.map g, aes if table.contains aes
      @log "apply: #{aes}(#{scale.id}):\t#{str}\t#{table.nrows()} rows"

    table = table.clone()
    @log "apply: table has #{table.nrows()} rows"
    @useScales table, aessTypes, posMapping, f
    #table.reloadSchema()
    table

  # @param posMapping maps aesthetic names to the scale
  #        that should be used
  #        e.g., median, q1, q3 should use 'y' position scale
  # @param {gg.Table} table
  invert: (table, aessTypes=null, posMapping={}) ->
    f = (table, scale, aes) =>
      str = scale.toString()
      #@log "invert: #{aes}\t#{str}"
      g = (v) -> if v? then  scale.invert(v) else null
      origDomain = scale.defaultDomain table.getColumn(aes)
      newDomain = null
      if table.contains aes
        table.map g, aes
        newDomain = scale.defaultDomain table.getColumn(aes)
      if scale.domain()?
        @log "invert: #{aes}(#{scale.id};#{scale.domain()}):\t#{origDomain} --> #{newDomain}"

    table = table.clone()
    @useScales table, aessTypes, posMapping, f
    table

  labelFor: -> null

  toString: (prefix="") ->
    arr = _.flatten _.map @scales, (map, aes) =>
      _.map map, (scale, type) => "#{prefix}#{scale.toString()}"
    arr.join('\n')


