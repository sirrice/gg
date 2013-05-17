_ = require 'underscore'

class gg.util.Graph

  constructor: (@idFunc=((node)->node)) ->
    @id2node = {}
    @pid2cid = {}     # parent id -> child ids
    @cid2pid = {}     # child id -> parent ids

  id: (@idFunc) ->

  add: (node) ->
    id = @idFunc node
    return @ if id of @id2node
    @id2node[id] = node
    @pid2cid[id] = {}  # store it as an associative map
    @cid2pid[id] = {}
    @

  rm: (node) ->
    id = @idFunc node
    return @ unless id of @id2node

    # delete all pointers
    _.each @cid2pid[id], (md, pid) => delete @pid2cid[pid][id]
    _.each @pid2cid[id], (md, cid) => delete @cid2pid[cid][id]

    # delete node and edge entries
    delete @pid2cid[id]
    delete @cid2pid[id]
    delete @id2node[id]
    @


  # add an edge
  connect: (from, to, metadata=null) ->
    if _.isArray from
      _.each from, (args) => @connect args...
      return @

    @add from
    @add to
    fid = @idFunc from
    tid = @idFunc to

    @pid2cid[fid][tid] = metadata
    @cid2pid[tid][fid] = metadata
    @


  # retrieve metadata for edge
  metadata: (from, to) ->
    fid = @idFunc from
    tid = @idFunc to
    return null unless fid of @id2node
    @pid2cid[fid][tid]

  # return a list of all edges in the graph
  edges: (filter=(metadata)->true) ->
    edges = []
    _.each @pid2cid, (cmap, pid) =>
      subEdges = _.map cmap, (metadata, cid) =>
        [@id2node[pid], @id2node[cid], metadata] if filter metadata
      edges.push.apply edges, subEdges
    edges

  # extract children whose edges pass the filter parameter
  # @param filter takes edge metadata as input
  children: (node, filter=((metadata)->true)) ->
    id = @idFunc node
    _.compact _.map @pid2cid[id], (metadata, id) =>
      @id2node[id] if filter metadata

  parents: (node, filter=(metadata)->true) ->
    id = @idFunc node
    _.compact _.map @cid2pid[id], (metadata, id) =>
      @id2node[id] if filter metadata

  sources: ->
    ids = _.filter _.keys(@id2node), (id) =>
      id not of @cid2pid or _.size(@cid2pid[id]) == 0
    _.map ids, (id) => @id2node[id]

  sinks: ->
    ids = _.filter _.keys(@id2node), (id) =>
      id not of @pid2cid or _.size(@pid2cid[id]) == 0
    _.map ids, (id) => @id2node[id]


  bfs: (f, sources=null) ->
    if sources
      sources = [sources] unless _.isArray sources
      queue = sources
    else
      queue = @sources()
    seen = {}
    while _.size queue
      node = queue.shift()
      id = @idFunc node
      continue if id of seen

      seen[id] = yes
      f node

      _.each @children(node), (child) =>
        queue.push child if child? and @idFunc(child) not of seen

  #
  # Visit nodes depth first
  #
  dfs: (f, node=null, seen=null) ->
    seen = {} unless seen?

    if node?
      id = @idFunc node
      return if id of seen
      seen[id] = yes
      f node

      _.each @children(node), (child) =>
        @dfs f, child, seen
    else
      _.each @sources(), (child) =>
        @dfs f, child, seen




