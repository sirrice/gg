#<< gg/stat/stat
#<< gg/xform/groupby



class gg.stat.Bin1D extends gg.xform.GroupBy
  @ggpackage = "gg.stat.Bin1D"
  @aliases = ['1dbin', 'bin', 'bin1d']

  constructor: (@spec={}) ->
    params = @spec.params or _.clone(@spec)
    @spec.params = params 
    defaults = 
      gbAttrs: ['x']
      aggFuncs: 
        count: "count"
        sum: "sum"
        y: "sum"
        total: "sum"
        avg: "avg"
    _.extend @spec.params, defaults
    super



class gg.stat.Bin2D extends gg.xform.GroupBy
  @ggpackage = "gg.stat.Bin2D"
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
        y: 
          type: 'sum'
          arg: 'z'
        total: 
          type: 'sum'
          arg: 'z'
    _.extend @spec.params, defaults
    super



