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
        total: 
          type: 'sum'
          col: 'z'

    params = new gg.util.Params @spec
    params.merge(new gg.util.Params defaults)
    params.merge @params
    @params = params

    super

  compute: (pairtable, params) ->
    table = pairtable.left()
    md = pairtable.right()
    set = md.any 'scales'

    cols = params.get 'cols'
    aggs = params.get 'aggs'
    nBins = @annotate.params.get 'nBins'

    xvals = @allVals set.get('x'), nBins[0]
    yvals = @allVals set.get('y'), nBins[1]
    xschema = new data.Schema ['x'], [data.Schema.numeric]
    yschema = new data.Schema ['y'], [data.Schema.numeric]
    xtable = new data.ColTable xschema, [xvals]
    ytable = new data.ColTable yschema, [yvals]
    xytable = xtable.cross(ytable)

    canonicalRow = table.any().clone()
    table = table.groupby cols, aggs

    f = ->
      row = canonicalRow.clone()
      row.set 'x', null
      row.set 'y', null
      _.each aggs, (agg) -> 
        _.each _.flatten([agg.alias]), (alias) ->
          row.set alias, 0
      row

    table = xytable.join(table, ['x', 'y'], 'left', null, f)
    pairtable.left table
    pairtable

  allVals: (scale, nbins) ->
    col = scale.aes
    type = scale.type
    switch type
      when data.Schema.ordinal
        scale.domain()
      when data.Schema.numeric
        minD = scale.domain()[0]
        maxD = scale.domain()[1]
        binRange = (maxD - minD) * 1.0
        binSize = binRange / nbins
        _.times nbins, (idx) ->
          idx * binSize + minD + (binSize / 2)
      when data.Schema.date
        domain = [domain[0].getTime(), domain[1].getTime()]
        [minD, maxD] = [domain[0], domain[1]]
        binRange = (maxD - minD) * 1.0
        binSize = binRange / nbins
        _.times nbins, (idx) ->
          new Date (Math.ceil(idx*binSize) + minD + binSize/2)



    


