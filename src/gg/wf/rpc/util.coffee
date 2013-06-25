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

    if removedEls?
      [removedEls, skip] = gg.wf.Inputs.flatten removedEls if _.isArray removedEls
      [flatinputs, skip] = gg.wf.Inputs.flatten inputs
      for input, idx in flatinputs
        if _.isArray removedEls
          input.env.merge removedEls[idx]
        else if _.isObject removedEls
          input.env.merge removedEls

    inputs


