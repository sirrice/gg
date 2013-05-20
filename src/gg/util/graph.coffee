#<< gg/util/log

_ = require 'underscore'

class gg.util.Graph

  constructor: (@idFunc=((node)->node)) ->
    @id2node = {}
    @pid2cid = {}     # parent id -> child ids
    @cid2pid = {}     # child id -> parent ids
    @log = gg.util.Log.logger "graph", gg.util.Log.WARN

  id: (@idFunc) ->

  add: (node) ->
    id = @idFunc node
    return @ if id of @id2node
    @id2node[id] = node
    @pid2cid[id] = {}  # store it as an associative map
    @cid2pid[id] = {}
    @log "add\t#{node}"
    @

  rm: (node) ->
    id = @idFunc node
    return @ unless id of @id2node

    # delete all pointers
    _.each @cid2pid[id], (edges, pid) => delete @pid2cid[pid][id]
    _.each @pid2cid[id], (edges, cid) => delete @cid2pid[cid][id]

    # delete node and edge entries
    delete @pid2cid[id]
    delete @cid2pid[id]
    delete @id2node[id]
    @log "rm\t#{node}"
    @


  # add an edge
  # subsequent calls will OVERWRITE existing metadata
  connect: (from, to, type, metadata=null) ->
    if _.isArray from
      _.each from, (args) => @connect args...
      return @

    @add from
    @add to
    fid = @idFunc from
    tid = @idFunc to

    @pid2cid[fid][tid] = {} unless @pid2cid[fid][tid]?
    @cid2pid[tid][fid] = {} unless @cid2pid[tid][fid]?
    @pid2cid[fid][tid][type] = metadata
    @cid2pid[tid][fid][type] = metadata
    @log "connect: #{from.name}! -> #{to.name}\t#{type}\t#{JSON.stringify metadata}"
    @


  # @param type null to match all edges, or set to a value to check if edge type exists
  edgeExists: (from, to, type) ->
    fid = @idFunc from
    tid = @idFunc to
    return false unless fid of @pid2cid and tid of @pid2cid[fid]
    edges = @pid2cid[fid][tid]
    if type? then  type of edges else true

  # retrieve metadata for edge
  # @param type null to fetch all metadatas, or set to value to retrive specific metadata
  metadata: (from, to, type) ->
    fid = @idFunc from
    tid = @idFunc to
    return null unless fid of @id2node
    edges = @pid2cid[fid][tid]
    return null unless edges?
    if type?
      edges[type]
    else
      _.map edges, (md, t) -> md

  nodes: (filter=(node)->true) ->
    _.filter _.values(@id2node), filter

  # return a list of all edges in the graph
  # that are of type @param type AND pass the filter
  #
  # @param type null to return all filtered edges, otherwise filter for specified edges
  # @param filter boolean function
  edges: (type, filter=(metadata)->true) ->
    ret = []
    _.each @pid2cid, (cmap, pid) =>
      _.map cmap, (edges, cid) =>
        _.map edges, (metadata, t) =>
          if (not type? or t == type) and filter metadata
            ret.push [@id2node[pid], @id2node[cid], t, metadata]
    ret

  # extract children whose edges pass the filter parameter
  # @param type null to check all edges, otherwise filter for specified edges
  # @param filter takes edge metadata as input
  #
  children: (node, type, filter=((metadata)->true)) ->
    id = @idFunc node
    children = []
    _.each @pid2cid[id], (edges, id) =>
      if _.any(edges, (metadata, t)-> (not type? or type == t) and filter(metadata))
        children.push @id2node[id]
    children

  parents: (node, type, filter=(metadata)->true) ->
    id = @idFunc node
    parents = []
    _.each @cid2pid[id], (edges, id) =>
      if _.any(edges, (metadata, t)-> (not type? or type == t) and filter(metadata))
        parents.push @id2node[id]
    parents

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




