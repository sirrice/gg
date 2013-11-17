#<< data/util/log

#
# The data model consists of a list of tuples (rows)
#
# Each tuple (row) contains a list of columns
# The data types include
# 1) atomic datatypes -- numeric, string, datetime
# 2) function datatype
# 3) object data type -- tuple knows how to inspect into it
# 3) array data type of mappings -- not inspected
#
# Attribute resolution
# 1) check for attributes containing atomic data types
# 2) check each column that is of type object
#
# Methods that start with "_" are update in place and return the same table
#


class data.Table
  @ggpackage = "data.Table"
  @log = data.util.Log.logger @ggpackage, "Table"


  # 
  # Required methods
  #

  iterator: -> throw Error("iterator not implemented")

  # is this columnar or row
  tabletype: -> "col"


  # 
  # schema related methods
  #

  has: (col, type) -> @contains col, type

  contains: (col, type) -> @schema.has col, type

  hasCols: (cols, types=null) ->
    _.all cols, (col, idx) =>
      type = null
      type = types[idx] if types? and types.length > idx
      @has col, type

  cols: -> @schema.cols

  ncols: -> @schema.ncols()

  # @override
  nrows: -> 
    i = 0
    @each (row) -> i += 1
    i


  # actually iterate through the iterator and create the rows
  getRows: -> @each (row) -> row

  raw: -> @each (row) -> row.raw()


  toJSON: ->
    schema: @schema.toJSON()
    data: _.toJSON @raw()
    tabletype: @tabletype()

  @fromJSON: (json) ->
    klass = @type2class(json.tabletype)
    klass ?= data.ColTable
    klass.fromJSON json

  toString: ->
    JSON.stringify @raw()


  @type2class: (tabletype="row") ->
    switch tabletype
      when "row", "RowTable"
        data.RowTable
      when "col", "ColTable"
        data.ColTable
      else
        null

  @deserialize: (str) ->
    json = JSON.parse str
    switch json.type
      when 'col'
        data.ColTable.deserialize json
      when 'row'
        data.RowTable.deserialize json
      else
        throw Error "can't deserialize data of type: #{json.type}"


  # Tries to infer a schema for a list of objects
  #
  # @param rows [ { attr: val, .. } ]
  @fromArray: (rows, schema=null, tabletype="row") ->
    klass = @type2class tabletype
    unless klass?
      throw Error "#{tabletype} doesnt have a class"

    klass.fromArray rows, schema

  @reEvalJS = /^{.*}$/
  @reVariable = /^[a-zA-Z]\w*$/
  @reNestedAttr = /^[a-zA-Z]+\.[a-zA-Z]+$/

  @isEvalJS: (s) ->@reEvalJS.test s
  @isVariable: (s) -> @reVariable.test s
  @isNestedAttr: (s) -> @reNestedAttr.test s



  #
  # Convenience methods that wrap operators
  #

  # @param f functiton to run.  takes data.Row, index as input
  # @param n number of rows
  each: (f, n=null) ->
    iter = @iterator()
    idx = 0
    ret = []
    while iter.hasNext()
      ret.push f(iter.next(), idx)
      idx +=1 
      break if n? and idx >= n
    iter.close()
    ret

  fastEach: (f, n) -> @each f, n

  limit: (n) ->
    new data.ops.Limit @, n

  offset: (n) ->
    new data.ops.Offset @, n

  sort: (cols, reverse=no) ->
    @orderby cols, reverse

  orderby: (cols, reverse=no) ->
    new data.ops.OrderBy @, cols, reverse

  filter: (f) ->
    new data.ops.Filter @, f

  cache: ->
    new data.ops.Cache @

  union: (tables...) ->
    tables = _.compact _.flatten tables
    new data.ops.Union @, tables

  cross: (table) ->
    new data.ops.Cross @, table, 'outer'

  join: (table, cols, type="outer") ->
    new data.ops.HashJoin @, table, cols, type

  exclude: (cols) ->
    keep = _.reject @cols(), (col) -> col in cols
    mappings = _.map keep, (col) =>
      alias: col
      type: @schema.type col
      cols: col
      f: _.identity
    @project mappings

  # Transforms individual columns
  #
  # @param mappings list of 
  #  { 
  #    alias:, 
  #    f:, 
  #    type: (default: sceham.object)
  #  }
  mapCols: (mappings) ->
    mappings = _.map mappings, (desc) ->
      desc.cols = desc.alias
    @project mappings

  project: (mappings) ->
    mappings = _.map mappings, (desc) =>
      if _.isString desc
        unless @has desc
          throw Error("project: #{desc} not in table. schema: #{@schema.cols}")
        {
          alias: desc
          f: _.identity
          type: @schema.type desc
          cols: desc
        }
      else
        desc

    new data.ops.Project @, mappings

  partition: (cols) ->
    new data.ops.Partition @, cols

  aggregate: (aggs) ->
    new data.ops.Aggregate @, aggs

  groupby: (cols, aggs) ->
    new data.ops.Aggregate(
      @partition(cols),
      aggs)

  partitionJoin: (table, cols, type="outer") ->
    partition1 = @partition cols
    partition2 = table.partition cols
    partition1.join partition2, cols, type
