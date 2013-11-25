#<< gg/stat/stat
#<< gg/xform/groupby



class gg.stat.Bin1D extends gg.xform.GroupBy
  @ggpackage = "gg.stat.Bin1D"
  @aliases = ['1dbin', 'bin', 'bin1d']

  parseSpec: ->
    defaults = 
      cols: ['x']
      aggs: 
        count: 'count'
        sum: 'sum'
        y: 'sum'
        total: 'sum'
        avg: 'avg'
    
    params = new gg.util.Params @spec
    params.merge(new gg.util.Params defaults)
    params.merge @params
    @params = params
    @params.ensure 'nBins', ['n', 'bins', 'nbins'], 20

    super

class gg.stat.Bin2D extends gg.xform.GroupBy
  @ggpackage = "gg.stat.Bin2D"
  @aliases = ['2dbin', 'bin2d']

  parseSpec: ->
    defaults = 
      cols: ['x', 'y']
      aggs: 
        z:
          type: 'count'
          col: 'z'
        count: 
          type: 'count'
          col: 'z'
        sum: 
          type: 'sum'
          col: 'z'
        r: 
          type: 'count'
          col: 'z'
        total: 
          type: 'sum'
          col: 'z'

    params = new gg.util.Params @spec
    params.merge(new gg.util.Params defaults)
    params.merge @params
    @params = params

    super

