#<< gg/stat/stat
#<< gg/xform/groupby



class gg.stat.Bin1D extends gg.xform.GroupBy
  @ggpackage = "gg.stat.Bin1D"
  @aliases = ['1dbin', 'bin', 'bin1d']

  parseSpec: ->
    defaults = 
      nBins: 20
      gbAttrs: ['x']
      aggFuncs: 
        count: 'count'
        sum: 'sum'
        y: 'sum'
        total: 'sum'
        avg: 'avg'
    defaults = new gg.util.Params defaults
    defaults.merge @params
    @params = defaults

    super

class gg.stat.Bin2D extends gg.xform.GroupBy
  @ggpackage = "gg.stat.Bin2D"
  @aliases = ['2dbin', 'bin2d']


  parseSpec: ->
    defaults = 
      nBins: 20
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
    defaults = new gg.util.Params defaults
    defaults.merge @params
    @params = defaults

    super

