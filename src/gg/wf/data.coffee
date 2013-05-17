#
# class that encapsulates data passed through the xforms


class gg.wf.Data
    constructor: (@table, @env=null) ->
      @env = new gg.wf.Env unless @env?

    clone: -> new gg.wf.Data @table, @env.clone()


    serialize: ->
        ""

#
# env contains cross-node state such as the set of split groups that
# a given node instance is part of.  a new copy is passed to child nodes so
# each node has a private version.
#
# env.groupPairs {Array}
#
#     Every time a split/partition is encountered, the group key name and value
#     are pushed onto groupPairs.
#     Every time a join is encountered, the stack is popped
#
class gg.wf.Env
  constructor: (stack) ->
    @groupPairs = _.findGood [stack, []]

  #groupPairs: -> @env.groupPairs
  lastGroupPair: ->
    if @groupPairs.length then _.last(@groupPairs) else null
  lastGroup: ->
    if @groupPairs.length then _.last(@groupPairs).val else null
  lastGroupName: ->
    if @groupPairs.length then _.last(@groupPairs).key else null
  popGroupPair: -> @groupPairs.shift()
  pushGroupPair: (key, val) -> @groupPairs.push {key: key, val: val}

  # Find the most recent group key
  # example: find facetX value or "1" if not found
  #
  #   data.group("facetX", "1")
  group: (key, defaultVal=null) ->
    for idx in  _.range(@groupPairs.length-1, -1, -1)
      pair =  @groupPairs[idx]
      if pair.key is key
        return pair.val
    return defaultVal

  # alias for @group
  get: (key, defaultVal) -> @group key, defaultVal

  contains: (key) ->
    _.any @groupPairs, (pair) ->
      pair.key is key

  clone: -> new gg.wf.Env _.clone(@groupPairs)

  toString: -> JSON.stringify @groupPairs

