#<< gg/wf/node



# Generalized split function
#
# @spec.f {Function} splitting function with signature: (table) -> [ {key:, table:}, ...]
class gg.wf.Split extends gg.wf.Node
  @ggpackage = "gg.wf.Split"
  @type = "split"

  parseSpec: ->
    # TODO: support groupby functions that return an
    # array of keys.
    @params.ensureAll
      gbkeyName: [['key'], @name]
      splitFunc: [['f'], @splitFunc]

  # This method must not depend on "this"!
  # @return array of {key: String, table: gg.Table} dictionaries
  splitFunc: (table, params) -> [ {table: table, key: null} ]

  compute: (data, params) ->
    table = data.table
    env = data.env
    splitFunc = params.get('splitFunc')
    splitFunc = @splitFunc unless _.isFunction splitFunc
    groups = splitFunc table, params

    unless groups? and _.isArray groups
      str = "Non-array result from calling split function"
      throw Error str

    gbkeyName = params.get 'gbkeyName'

    @log "#{groups.length} partitions"

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

    pstore = @pstore()
    f = (data, inpath) =>
      res = @compute data, @params
      
      # write provenance
      _.times res.length, (lastIdx) =>
        outpath = _.clone inpath
        outpath.push lastIdx
        pstore.writeData outpath, inpath

      res

    outputs = gg.wf.Inputs.mapLeaves @inputs, f
    for output, idx in outputs
      @output idx, output

    outputs



# Shorthand for non-overlapping group-by
# on table column(s)
class gg.wf.Partition extends gg.wf.Split
  @ggpackage = "gg.wf.Partition"

  constructor: ->
    super
    @name = @spec.name or "partition-#{@id}"

  splitFunc: (table, params) ->
    gbfunc = params.get 'f'
    gbfunc = (()->"1") unless gbfunc? and _.isFunction gbfunc
    table.split gbfunc


# Shorthand for non-overlapping group-by
# on table column(s)
class gg.wf.PartitionCols extends gg.wf.Split
  @ggpackage = "gg.wf.PartitionCols"

  constructor: ->
    super
    @name = @spec.name or "partitioncols-#{@id}"

  parseSpec: ->
    super
    cols = @params.get 'cols'
    cols = [@params.get 'col'] unless cols?
    cols = _.compact _.flatten cols
    unless cols? and cols.length > 0
      @log.info "PartitionCols setup with 0 cols"
    @params.put 'cols', cols


  compute: (data, params) ->
    [table, env] = [data.table, data.env]
    cols = params.get 'cols'
    gbkeyName = params.get 'gbkeyName'
    @log "split on cols: #{cols}"

    if not(cols? and cols[0]?)
      @log "no cols, using original table"
      data.env.put gbkeyName, null
      datas = [ data ]
    else
      f = (row) -> _.first _.map cols, ((col) -> row.get(col))
      groups = data.table.split f

      @log "#{groups.length} partitions"
      datas = _.map groups, (group, idx) =>
        subtable = group.table
        key = group.key
        newData = new gg.wf.Data subtable, env.clone()
        newData.env.put gbkeyName, key
        newData
    
    datas



