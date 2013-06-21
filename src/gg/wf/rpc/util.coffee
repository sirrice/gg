class gg.wf.rpc.Util
  @serializeOne: (table, env, params) ->
    # To prepare the env objects for transport:
    # 1. remove SVG/dom elements
    removedEls =
      svg: env.rm 'svg'

    tableJson = table.toJSON()
    envJson = env.toJSON()
    paramsJSON = if params? then params.toJSON() else null

    payload =
      table: tableJson
      env: envJson
      params: paramsJSON

    [payload, removedEls]


  @serializeMany: (tables, envs, params) ->
    # To prepare the env objects for transport:
    # 1. remove SVG/dom elements
    # 2. reject environments/params that contain functions
    #    or do something smarter?
    removedEls =
      _.map envs, (env) ->
        {svg: env.rm('svg')}

    tableJSONs = _.map tables, (table) -> table.toJSON()
    envJSONs = _.map envs, (env) -> env.toJSON()
    paramsJSON = if params? then params.toJSON() else null

    payload =
      tables: tableJSONs
      envs: envJSONs
      params: paramsJSON

    [payload, removedEls]


  @deserializeOne: (respData, removedEls={}) ->
    table = gg.data.RowTable.fromJSON respData.table
    env = gg.wf.Env.fromJSON respData.env
    env.merge removedEls
    [table, env]


  @deserializeMany: (respData, removedEls=null) ->
    tables = _.map respData.tables, (json) ->
      gg.data.RowTable.fromJSON json

    envs = _.map respData.envs, (json, i) ->
      env = gg.wf.Env.fromJSON json
      if removedEls?
        if _.isArray removedEls
          env.merge removedEls[i]
        else if _.isObject removedEls
          env.merge removedEls
      env

    [tables, envs]


