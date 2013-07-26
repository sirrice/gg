#<< gg/util/util

class gg.wf.Inputs
  @isLeafArray: (arr) ->
    arr? and (arr.length == 0 or not _.isArray(arr[0]))

  @pick: (inputs, path) ->
    cur = inputs
    for idx in path
      return null if idx >= cur.length or not _.isArray(cur)
      cur = cur[idx]
    cur


  # @param f function that takes a list of data objects as input
  #         ([data...]) -> data or [data...]
  # split -> split -> barrier -> join -> join
  # [t]
  # [ [t1, t2] ]
  # [ [ [a, b, c], [x, y] ] ]
  # [ [ abc, xy ] ]
  # [ abcxy ]
  @mapLeafArrays: (inputs, f, path=[]) ->
    return unless inputs?
    return inputs if inputs.length == 0
    _.map inputs, (subinput, idx) ->
      path.push idx
      res = if gg.wf.Inputs.isLeafArray subinput
        f subinput, _.clone(path)
      else
        gg.wf.Inputs.mapLeafArrays subinput, f, path
      path.pop()
      res


  # @param f function that takes a single data object as input
  #          (data) -> data or [data...]
  # @return transformed datas with the same hirearchical structure
  @mapLeaves: (inputs, f, path=[]) ->
    return unless inputs?

    if _.isArray inputs
      _.map inputs, (input, idx) ->
        path.push idx
        res = if _.isArray input
          gg.wf.Inputs.mapLeaves input, f, path
        else
          f input, _.clone(path)
        path.pop()
        res
    else
      f inputs, path

  # Flatten the input array but compute metadata for the nested structure
  # @return [array, metadata]
  #         array:    flattened array of gg.wf.Data objects
  #         metadata: metadata that tracks each object in array 
  #           to originial structure -- the path to the object
    #         e.g., [ [a, [b]] ]: 
    #               a has path [0, 0]
    #               b has path [0, 1, 0]
  @flatten: (inputs, md=[], arr=[], path=[]) ->
    # md: array idx -> original indices

    _.each inputs, (input, idx) ->
      path.push idx
      if _.isArray input
        gg.wf.Inputs.flatten input, md, arr, path
      else
        md[arr.length] = _.clone path
        arr.push input
      path.pop()

    [arr, md]

  # Reconstruct hierarchical array structure from a flattened array and the metadata
  # We expect that for a hierarchical array Arr:
  #
  #   [flat, md] = gg.wf.Inputs.flatten(Arr)
  #   Arr == gg.wf.Inputs.unflatten(flat, md)
  #
  @unflatten: (arr, md) ->
    output = []
    setAtPath = (o, path, data) ->
      idx = _.first path
      path = _.rest path
      if path.length == 0
        o[idx] = data
      else
        o[idx] = [] unless o.length > idx
        setAtPath o[idx], path, data

    _.each arr, (data, idx) ->
      path = md[idx]
      setAtPath output, path, data

    output






#
# class that encapsulates data passed through the xforms
#
class gg.wf.Data
  @ggpackage = "gg.wf.Data"
  constructor: (@table, @env=null) ->
    @env = new gg.wf.Env unless @env?

  clone: -> new gg.wf.Data @table.clone(), @env.clone()

  toJSON: ->
    tableJson = null
    if @table?
      tableJson = @table.toJSON()
    table: tableJson
    env: @env.toJSON()

  @fromJSON: (json) ->
    table = null
    if json.table?
      table = gg.data.RowTable.fromJSON json.table
    new gg.wf.Data(
      table
      gg.wf.Env.fromJSON json.env
    )


#
# Data structure to implement a pseuda-monad
#
class gg.wf.Env extends gg.util.Params
  @ggpackage = "gg.wf.Env"
  clone: ->
    # compute all the non-JSONable elements
    removedEls =
      svg: _.clone(@rm 'svg')

    _.each _.keys(@data), (key) =>
      if _.isFunction @data[key]
        removedEls[key] = @rm key

    clone = gg.wf.Env.fromJSON @toJSON()
    @merge removedEls
    clone.merge removedEls
    clone



  @fromJSON: (json) ->
    data = _.fromJSON json
    new gg.wf.Env data

