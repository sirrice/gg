#<< gg/data/table

class gg.data.RowTable extends gg.data.Table
  @ggpackage = "gg.data.RowTable"

  constructor: (@schema, rows=[]) ->
    throw Error("schema not present") unless @schema?
    @rows = []
    _.each rows, (row) => @addRow row
    @log = gg.data.Table.log


  # XXX: This method infers schema information, and which may
  #      lose or be inconsistent with existing schema info
  @fromArray: (rows) ->
    schema = gg.data.Table.inferSchemaFromObjs rows
    table = new gg.data.RowTable schema, rows
    table


  @toRow: (data, schema) ->
    if _.isType data, gg.data.Row
      if data.schema != schema
        row = data.clone()
        row.schema = schema
        row
      else
        data
    else
      new gg.data.Row data, schema

  setSchema: (schema) ->
    @each (row) -> row.schema = schema
    @schema = schema
    @

  reloadSchema: ->
    rows = _.map(@rows, (row) -> row.raw())
    @setSchema gg.data.Table.inferSchemaFromObjs rows
    @

  nrows: -> @rows.length
  ncols: -> @schema.nkeys()
  colNames: -> @schema.attrs()
  contains: (attr, type) -> @schema.contains attr, type

  cloneShallow: ->
    rows = @rows.map (row) -> row
    new gg.data.RowTable @schema.clone(), rows

  cloneDeep: ->
    rows = @rows.map (row) => row.clone()
    new gg.data.RowTable @schema.clone(), rows

  # In-place sort function
  sort: (cmp, update=yes) ->
    if update
      @rows.sort cmp
      @
    else
      clone = @clone()
      clone.sort cmp, yes

  merge: (table) ->
    # ensure schemas
    if _.isSubclass table, gg.data.RowTable
      @rows.push.apply @rows, table.rows
    else
      throw Error("merge not implemented for #{@constructor.name}")
    @

  @merge: (tables) ->
    if tables.length == 0
      new gg.data.RowTable @schema
    else
      t = tables[0].cloneShallow()
      for t2, idx in tables
          t.merge(t2) if idx > 0
      t


  # Horizontally split table using an arbitrary splitting function
  # (preserves all existing columns)
  split: (gbfunc) ->
    if _.isString gbfunc
      attr = gbfunc
      gbfunc = ((key) -> (row) -> row.get(key))(attr)

    keys = {}
    groups = {}
    _.each @rows, (row) ->
      key = gbfunc row
      jsonKey = JSON.stringify key
      groups[jsonKey] = [] unless jsonKey of groups
      groups[jsonKey].push row
      keys[jsonKey] = key

    ret = []
    schema = @schema.clone()
    _.each groups, (rows, jsonKey) ->
      partition = new gg.data.RowTable schema, rows
      ret.push {key: keys[jsonKey], table: partition}
    ret



  # Partition table on a set of table columns
  # Removes those columns from each partition's tuples
  partition: (cols) ->
    cols = _.flatten [cols]
    cols = _.filter cols, (col) => @schema.contains col

    keys = {}
    groups = {}
    _.each @rows, (row) ->
      key = _.map cols, (col) -> row.get col
      jsonKey = JSON.stringify key
      groups[jsonKey] = [] unless jsonKey of groups
      groups[jsonKey].push row
      keys[jsonKey] = key

    ret = []
    schema = @schema.clone()
    @log "removing #{cols}"
    _.each cols, (col) -> schema.rmColumn col
    _.each groups, (rows, jsonKey) ->
      _.each rows, (row) -> row.rmColumns cols
      partition = new gg.data.RowTable schema, rows
      gg.wf.Stdout partition, null, 5, @log
      ret.push {key: keys[jsonKey], table: partition}
    ret


  flatten: (cols=null, recursive=false) ->
    table = new gg.data.RowTable @schema.flatten(cols, recursive)
    @each (row) -> table.merge row.flatten(cols, recursive)
    table

  # 1 to 1 mapping function
  #
  # @param colname either a string, or an object of {key: xform} pairs
  # @param {Function|boolean} funcOrUpdate
  #        if colname is a string, funcOrUpdate is a transformation
  #        function (val, row) -> newVal.
  #        if colname is an object, used as update (see below)
  # @param {boolean} update
  #        true if transformation should update the table
  #        false if rows should be new, with only columns specified by transformation
  #
  transform: (colname, funcOrUpdate=yes, update=yes) ->
    if _.isObject colname
        mapping = colname
        update = funcOrUpdate
    else
        mapping = {}
        mapping[colname] = funcOrUpdate

    if update
      @each (row) =>
        newrow = @transformRow row, mapping
        row.merge newrow
      @reloadSchema()
      @
    else
      newrows = @each (row) => @transformRow row, mapping
      gg.data.RowTable.fromArray newrows

  # constructs a new object and populates it using mapping specs
  transformRow: (row, mapping) ->
    ret = {}
    _.each mapping, (f, newattr) =>
      newvalue = try
        f row
      catch error
        @log.error row.raw()
        @log.error f.toString()
        @log.error error
        throw error

      if _.isArray newvalue
        if gg.data.Table.reNestedAttr.test newattr
          [attr1, attr2] = newattr.split(".")
          ret[attr1] = {} unless attr1 of ret
          _.each newvalue, (el, idx) ->
            if idx >= ret[attr1].length
              ret[attr1].push {}
            ret[attr1][attr2] = el
        else
          throw Error("mapping arrays need to be nested")
      else
        ret[newattr] = newvalue
    ret


  # create new table containing the (exactly same)
  # rows from current table, with rows failing the filter
  # test not present
  filter: (f) ->
    newrows = []
    @each (row, idx) -> newrows.push row if f(row, idx)
    new gg.data.RowTable @schema, newrows


  # transforms the values of column(s) on a per-column basis
  # Destructively updates!
  # Each mapping function takes the current field as input
  # XXX: doesn't perform nested map operations correctly
  map: (fOrMap, colName=null) ->
    if _.isFunction fOrMap
      unless colName?
        throw Error("RowTable.map without colname!")
      f = fOrMap
      fOrMap = {}
      fOrMap[colName] = f

    schema = @schema
    @each (row, idx) ->
      _.each fOrMap, (f, col) ->
        if schema.inArray col
          arr = _.map row.get(col), f
          row.set col, arr
        else
          newv = f(row.get(col))
          row.set col, newv

    # reload schema if any new cols were added
    unless _.all(fOrMap, (f,col) => @contains col)
      @reloadSchema()
    @

  addConstColumn: (name, val, type=null) ->
    type = gg.data.Schema.type(val) unless type?
    @addColumn name, _.repeat(@nrows(), val), type

  addColumn: (name, vals, type=null) ->
    if vals.length != @nrows()
      throw Error("column has #{vals.length} values,
        table has #{@rows.length} rows")

    unless type?
      type = if vals.length is 0
        {type: gg.data.Schema.unknown, schema: null}
      else
        gg.data.Schema.type vals[0]

    if @schema.contains name
      if type.type != @schema.type name
        throw Error("column #{name} already exists in table and
           #{type} != #{@schema.type name}")
      else
        @log.warn "column #{name} already exists in table"

    @schema.addColumn name, type.type, type.schema
    @rows.forEach (row, idx) => 
      row.addColumn(name, vals[idx])
      row.schema = @schema
    @

  addRow: (row) ->
    # enforce schema
    @rows.push gg.data.RowTable.toRow(row, @schema)
    @

  get: (row, col=null) ->
    if row >= 0 and row < @rows.length
      if col?
          @rows[row].get col
      else
          @rows[row]
    else
      null

  getCol: (col) -> @getColumn col
  getColumn: (col) ->
    # XXX: hack.  make it do the right thing if no rows
    if @nrows() > 0 and @schema.contains col
      if @schema.inArray col
        _.flatten _.times @nrows(), (idx) => @get(idx, col)
      else
        _.times @nrows(), (idx) => @get(idx, col)
    else if @nrows() == 0 and @schema.contains col
      []
    else
      if @schema.contains col and @schema.isArray col
        []
      else
        null

  asArray: -> _.map @rows, (row) -> row
  raw: -> _.map @rows, (row) -> row.raw()
  rows: @rows

  toJSON: ->
    schema: @schema.toJSON()
    data: @raw()

  @fromJSON: (json) ->
    schemaJson = json.schema
    dataJson = json.data

    schema = gg.data.Schema.fromSpec schemaJson
    rawrows = dataJson

    new gg.data.RowTable schema, rawrows




