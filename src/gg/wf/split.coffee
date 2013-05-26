#<< gg/wf/node



# Generalized split function
#
# @spec.f {Function} splitting function with signature: (table) -> [ {key:, table:}, ...]
class gg.wf.Split extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    @outPort2childInPort = {}

    # TODO: support groupby functions that return an
    # array of keys.
    @type = "split"
    @name = _.findGood [@spec.name, "split-#{@id}"]
    @gbkeyName = _.findGood [@spec.key, @name]
    @splitFunc = _.findGood [@spec.f, @splitFunc]

  # @return array of {key: String, table: gg.Table} dictionaries
  splitFunc: (table, env, node) -> []

  cloneSubplan: (parent, parentPort, stop) ->
    super


  findMatchingJoin: ->
    @log "\tfindMatch children: #{_.map(@children, (c)->c.name+"-"+c.id).join("  ")}"
    port = 0
    outPort = @in2out[port]
    childPort = @out2child[outPort]

    port = childPort
    ptr = @children[outPort]
    n = 1
    while ptr?
      @log "\tfindMatch: #{ptr.name}-#{ptr.id}(#{port})"
      n += 1 if ptr.type is 'split'
      n -= 1 if ptr.type is 'join'
      break if n == 0

      if ptr.hasChildren()
        outPort = ptr.in2out[port]
        childPort = ptr.out2child[outPort]
        child = ptr.children[outPort]
        childStr = null
        childStr ="#{child.name}-#{child.id}(#{childPort})" if child?
        @log "\tfindMatch: (#{port}->#{outPort}) -> #{childStr}"


        ptr = child
        port = childPort
      else
        ptr = null

    name = if ptr? then "#{ptr.name}-#{ptr.id}" else null
    @log "split #{@name}-#{@id}: matching join #{name}"
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
        [child, childCb] = @children[0].cloneSubplan @, 0, stop
        outputPort = @addChild child, childCb
        @connectPorts 0, outputPort, childCb.port
        child.addParent @, outputPort, childCb.port

  #
  # add a new child instance
  #
  addChild: (child, inputCb=null) ->
    childport = if inputCb? then inputCb.port else -1
    myStr = "#{@base().name} port(#{@nChildren()})"
    childStr = "#{child.base().name} port(#{childport})"
    @log "addChild: #{myStr} -> #{childStr}"

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


