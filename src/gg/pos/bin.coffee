#<< gg/pos/position
#<< gg/xform/groupby

class gg.pos.Bin2D extends gg.xform.GroupBy
  @ggpackage = "gg.pos.Bin2D"
  @aliases = ['2dbin', 'bin2d']

  constructor: (@spec={}) ->
    params = @spec.params or _.clone(@spec)
    @spec.params = params 
    defaults = 
      gbAttrs: ['x', 'y']
      aggFuncs: 
        count: 
          type: 'count'
          arg: 'z'
        sum: 
          type: 'sum'
          arg: 'z'
        r: 
          type: 'count'
          arg: 'z'
        total: 
          type: 'sum'
          arg: 'z'
    _.extend @spec.params, defaults
    @log.debug @spec.params
    super


  getGrouper: (gbAttrs, schema, scales, nBins) ->
    groupers = _.map gbAttrs, (gbAttr, idx) ->
      type = schema.type gbAttr
      scale = scales.scale gbAttr, type
      domain = scale.range()
      new gg.xform.SingleKeyGrouper gbAttr, type, domain, nBins[idx]
    grouper = new gg.xform.MultiKeyGrouper groupers
    @log "group has #{grouper.nBins} bins"
    @log "groupBins: #{grouper.groupBins}"
    grouper

