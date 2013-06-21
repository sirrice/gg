#<< gg/wf/node



# Generalized split function
#
# @spec.f {Function} splitting function with signature: (table) -> [ {key:, table:}, ...]
class gg.wf.Split extends gg.wf.Node
  @ggpackage = "gg.wf.Split"

  constructor: (@spec={}) ->
    super @spec
    @type = "split"
    @name = _.findGood [@spec.name, "split-#{@id}"]

    # TODO: support groupby functions that return an
    # array of keys.
    @params.ensureAll
      gbkeyName: [['key'], @name]
      splitFunc: [['f'], @splitFunc]

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



  compute: (table, env, params) ->
    groups = params.get('splitFunc') table, env, params
    unless groups? and _.isArray groups
      str = "Non-array result from calling split function"
      throw Error str


    gbkeyName = params.get 'gbkeyName'

    datas = _.map groups, (group, idx) =>
      subtable = group.table
      key = group.key
      newData = new gg.wf.Data subtable, env.clone()
      newData.env.put gbkeyName, key
      newData

    datas


  run: ->
    unless @ready()
      str = "Split not ready, expects #{@inputs.length} inputs"
      throw Error str

    data = @inputs[0]
    table = data.table
    env = data.env

    datas = @compute table, env, @params
    if datas.length > 1000
      throw Error("I don't want to support more than 1000 groups!")

    @allocateChildren datas.length

    _.each datas, (data, idx) => @output idx, data

    console.log "returning #{datas.length} datas"
    datas


# Shorthand for non-overlapping group-by
# on table column(s)
class gg.wf.Partition extends gg.wf.Split
  @ggpackage = "gg.wf.Partition"

  constructor: ->
    super
    @name = _.findGood [@spec.name, "partition-#{@id}"]

    gbfunc = @params.get('f') or (()->"1")
    splitFunc = (table) -> table.split gbfunc
    @params.put 'splitFunc', splitFunc


# Shorthand for non-overlapping group-by
# on table column(s)
class gg.wf.PartitionCols extends gg.wf.Split
  @ggpackage = "gg.wf.PartitionCols"

  constructor: ->
    super
    @name = _.findGood [@spec.name, "partition-#{@id}"]

    unless @params.contains 'cols'
      if @params.contains 'col'
        @params.put 'cols', [@params.get 'col']
      else
        throw Error("Partition needs >0 columns")

    cols = _.flatten(@params.get 'cols')
    @params.put 'cols', cols


  compute: (table, env, params) ->
    cols = params.get 'cols'
    f = (row) -> _.first _.map cols, ((col) -> row.get(col))
    groups = table.split f
    gbkeyName = params.get 'gbkeyName'
    datas = _.map groups, (group, idx) =>
      subtable = group.table
      key = group.key
      newData = new gg.wf.Data subtable, env.clone()
      newData.env.put gbkeyName, key
      newData

    datas



