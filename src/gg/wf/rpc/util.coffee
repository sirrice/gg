class gg.wf.rpc.Util

  @serialize: (pairtable, params) ->
    # To prepare the env objects for transport:
    # 1. remove SVG/dom elements
    # 2. reject environments/params that contain functions
    #    or do something smarter?
    md = pairtable.right()
    clientCols = ['svg', 'event']
    removedEls = _.o2map clientCols, (col) ->
      if md.has col
        [col, md.all(col)]

    md = md.exclude clientCols if clientCols.length > 0

    paramsJSON = if params? then params.toJSON() else null

    payload =
      table: pairtable.left().toJSON()
      md: pairtable.right().toJSON()
      params: paramsJSON

    [payload, removedEls]



  @deserialize: (respData, removedEls={}) ->
    table = data.Table.fromJSON respData.table
    md = data.Table.fromJSON respData.md

    for col, colData of removedEls
      unless colData.length == md.nrows()
        throw Error("rpc.deserialize: data len (#{md.nrows()}) !=
          removedEls len (#{colData.length}) on col #{col}")
      md = md.setCol col, colData

    new data.PairTable table, md
