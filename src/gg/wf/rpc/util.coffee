class gg.wf.rpc.Util

  @serialize: (inputs, params) ->
    # To prepare the env objects for transport:
    # 1. remove SVG/dom elements
    # 2. reject environments/params that contain functions
    #    or do something smarter?
    removedEls = gg.wf.Inputs.mapLeaves inputs, (data) ->
      {svg: data.env.rm('svg')}

    inputsJSONs = _.toJSON inputs
    paramsJSON = if params? then params.toJSON() else null

    payload =
      inputs: inputsJSONs
      params: paramsJSON

    [payload, removedEls]



  @deserialize: (respData, removedEls=null) ->
    inputs = _.fromJSON respData.inputs

    mergeREs = (arr, res) ->
      unless _.isArray res
        gg.wf.Inputs.mapLeaves arr, (data) ->
          data.env.merge res
        return

      if arr.length != res.length
        throw Error("rpc.deserialize: data len (#{arr.length}) !=
          removedEls len (#{res.length})")

      for idx in _.range(arr.length)
        mergeREs arr[idx], res[idx]

    mergeREs inputs, removedEls if removedEls?
    inputs



