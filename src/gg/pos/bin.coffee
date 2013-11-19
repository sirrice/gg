#<< gg/pos/position
#<< gg/xform/groupby

class gg.pos.Bin2D extends gg.xform.GroupBy
  @ggpackage = "gg.pos.Bin2D"
  @aliases = ['2dbin', 'bin2d']

  parseSpec: ->
    defaults = 
      nBins: 20
      cols: ['x', 'y']
      aggs: 
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
    defaults = new gg.util.Params defaults
    defaults.merge @params
    @params = defaults

    super

