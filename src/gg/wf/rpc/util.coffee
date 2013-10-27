class gg.wf.rpc.Util

  @serialize: (pairtable, params) ->
    # To prepare the env objects for transport:
    # 1. remove SVG/dom elements
    # 2. reject environments/params that contain functions
    #    or do something smarter?
    md = pairtable.getMD()
    clientCols = ['svg', 'event']
    removedEls = _.o2map clientCols, (col) ->
      if md.has col
        [col, md.getColumn(col)]

    for col in clientCols
      md = md.rmColumn col

    paramsJSON = if params? then params.toJSON() else null

    payload =
      table: pairtable.getTable().toJSON()
      md: pairtable.getMD().toJSON()
      params: paramsJSON

    [payload, removedEls]



  @deserialize: (respData, removedEls={}) ->
    table = gg.data.Table.fromJSON respData.table
    md = gg.data.Table.fromJSON respData.md

    for col, colData of removedEls
      unless colData.length == md.nrows()
        throw Error("rpc.deserialize: data len (#{md.nrows()}) !=
          removedEls len (#{colData.length}) on col #{col}")
      md = md.addColumn col, colData

    new gg.data.PairTable table, md
