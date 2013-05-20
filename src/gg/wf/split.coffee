#<< gg/wf/node



# Generalized split function
#
# @spec.f {Function} splitting function with signature: (table) -> [ {key:, table:}, ...]
class gg.wf.Split extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    # TODO: support groupby functions that return an
    # array of keys.
    @type = "split"
    @name = _.findGood [@spec.name, "split-#{@id}"]
    @gbkeyName = _.findGood [@spec.key, @name]
    @splitFunc = _.findGood [@spec.f, @splitFunc]

  # @return array of {key: String, table: gg.Table} dictionaries
  splitFunc: (table, env, node) -> []

  findMatchingJoin: ->
    ptr = @children[0]
    n = 1
    while ptr?
      n += 1 if ptr.type is 'split'
      n -= 1 if ptr.type is 'join'
      break if n == 0
      ptr = if ptr.hasChildren() then ptr.children[0] else null
    ptr

  #
  # ensure that there are @n instances of this operator's
  # child node.  One for each partition.
  #
  allocateChildren: (n) ->
    if @hasChildren()
      stop = @findMatchingJoin()

      while @children.length < n
        idx = @children.length
        [child, childCb] = @children[0].cloneSubplan @, stop
        outputPort = @addChild child, childCb
        @connectPorts 0, outputPort
        child.addParent @, childCb.port

  #
  # add a new child instance
  #
  addChild: (child, inputCb=null) ->
    childport = if inputCb? then inputCb.port else -1
    myStr = "#{@base().name} port(#{@nChildren()})"
    childStr = "#{child.base().name} port(#{childport})"
    @log.warn "addChild: #{myStr} -> #{childStr}"

    outputPort = @children.length
    @children.push child
    @addOutputHandler outputPort, inputCb if inputCb?
    outputPort




  run: ->
    unless @ready()
      str = "Split not ready, expects #{@inputs.length} inputs"
      throw Error str

    data = @inputs[0]
    table = data.table
    env = data.env

    groups = @splitFunc table, env, @
    unless groups? and _.isArray groups
      str = "#{@name}: Non-array result from calling
             split function"
      throw Error str


    # TODO: parameterize MAXGROUPS threshold
    numDuplicates = groups.length
    if numDuplicates > 1000
      throw Error("I don't want to support more than 1000 groups!")
    @log.err "Split created #{numDuplicates} groups"
    @allocateChildren numDuplicates


    idx = 0
    _.each groups, (group) =>
      subtable = group.table
      key = group.key
      newData = new gg.wf.Data subtable, data.env.clone()
      newData.env.pushGroupPair @gbkeyName, key
      @output idx, newData
      idx += 1
      @log.err "group #{JSON.stringify key}: #{subtable.nrows()} rows"
    groups


# Shorthand for non-overlapping group-by functionality
class gg.wf.Partition extends gg.wf.Split
  constructor: ->
    super

    @name = _.findGood [@spec.name, "partition-#{@id}"]
    @gbfunc = @spec.f or @gbfunc
    @splitFunc = (table) -> table.split @gbfunc

  gbfunc: -> 1


