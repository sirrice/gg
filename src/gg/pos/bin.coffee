#<< gg/pos/position
#<< gg/xform/groupby

class gg.pos.Bin2D extends gg.xform.GroupBy
  @ggpackage = "gg.pos.Bin2D"
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

