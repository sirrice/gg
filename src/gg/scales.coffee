#<< gg/scale
#

# Scales
#
# Scales per
#
# --------
#
# applyNode: -> (table, env) ->
# unapplyNode: -> (table, env) ->
# train: -> (table, env) ->
#


# Convenience class that creates identical gg.Scales objects
# from a single spec
#
# Used to create layer, panel and facet level copies of gg.Scales
# when training the scales
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
      @paneDefaults[scale.aesthetic] = scale
      console.log "pane default: #{scale.aesthetic}\t#{s}"

    # load layer defaults
    if @layerSpecs? and @layerSpecs.length > 0
      _.each @layerSpecs, (lspec, idx) =>
        if lspec.scales?
          _.each lspec.scales, (s) =>
            scale = gg.Scale.fromSpec s
            key = [idx, scale.aesthetic]
            @layerDefaults[key] = scale

  addLayerDefaults: (layerIdx, lspec) ->
    throw Error("gg.ScaleFactory: layer scales not implemented")

  scale: (aes, layerIdx=null) ->
      if layerIdx? and [layerIdx, aes] of @layerDefaults
          @layerDefaults[[layerIdx, aes]].clone()
      else if aes of @paneDefaults
          @paneDefaults[aes].clone()
      else
          gg.Scale.defaultFor aes

  scales: (aesthetics, layerIdx=null) ->
      scales = new gg.ScalesSet @
      _.each aesthetics, (aes) =>
          scales.scale(@scale aes, layerIdx)
          console.log "made scale #{scales.scale(aes)}"
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

  clone: () ->
    ret = new gg.ScalesSet @factory
    ret.spec = @spec
    ret.merge @
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
    _.map keys, (key) ->
      if key of gg.Scale.xs
        gg.Scale.xs
      else if key of gg.Scale.ys
        gg.Scale.ys
      else
        key
    _.uniq _.flatten keys



  ensureScales: (aess) ->
    _.each aess, (aes) =>
        @scale(gg.Scale.defaultFor aes) if ! @scale(aes)
    @


  contains: (aes, type=null) -> aes of @scales and (not type or type of @scales[aes])
  scale: (aesOrScale, type=null) ->
    if _.isString aesOrScale
        aes = aesOrScale
        aes = 'x' if aes in gg.Scale.xs
        aes = 'y' if aes in gg.Scale.ys
        @scales[aes] = {} if aes not of @scales

        if type is null
            vals = _.values @scales[aes]
            if vals? and vals.length > 0 then vals[0] else null
        else
            @scales[aes][type] = @factory.scale aes if type not of @scales[aes]
            @scales[aes][type]

    else if aesOrScale?
        scale = aesOrScale
        aes = scale.aesthetic
        @scales[aes] = {} if aes not of @scales
        @scales[aes][scale.type] = scale



  # @param scalesArr array of gg.Scales objects
  # @return a single gg.Scales object that merges the inputs
  @merge: (scalesArr) ->
    if scalesArr.length is 0
        return null
    ret = scalesArr[0].clone()
    _.each scalesArr, (scales) ->
        ret.merge scales
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
        if @contains aes, type
          @scale(aes, type).mergeDomain scales.scale(aes, type).domain()
        else if insert
          @scale(scales.scale(aes, type).clone())
    @


  # each aesthetic will be trained
  # multiple layers may use same aesthetics so need to cope with
  # overlaps
  train: (table, aess=null) ->
    console.log "scale training on #{aess} #{_.keys @scales}"
    aess = _.keys @scales unless aess?
    _.each aess, (aes) =>
      scale = @scale(aes)

      col = table.getColumn(aes)
      # XXX: perform type checking.  Just assume all continuous for now
      if col?
        scale.mergeDomain scale.defaultDomain col
    @

  setRanges: (pane) ->
    _.each pane.aesthetics(), (aes) =>
      _.each _.values(@scales[aes]), (s) =>
        if aes in ['x', 'y']
          s.range pane.rangeFor aes
    @


  toString: ->
    arr = _.flatten _.map @scales, (map, aes) =>
        _.map map, (scale, type) =>
            d3Scale = scale.d3Scale
            _.flatten([aes, '->', type, d3Scale.domain(), d3Scale.range()]).join(' ')
    arr.join('\n')

  apply: -> null

  # destructively invert table on aess columns
  #
  # @param {gg.Table} table
  invert: (table, aess=null) ->
    aess = _.keys @scales unless aess?

    table = table.cloneShallow()
    table.each (row, idx) =>
      _.each aess, (aes) =>
        row[aes] = @scale(aes).invert(row[aes]) if aes of row
    table

  labelFor: -> null




