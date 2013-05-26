

# Helper functions that return workflow nodes
# that perform different group-bys
class gg.xform.Split

  @createNode: (name, gbspec) ->
    if _.isString gbspec
      gg.xform.Split.byColValues name, gbspec
    else if _.isFunction gbspec
      gg.xform.Split.byFunction name, gbspec
    else if _.isArray(gbspec) and gbspec.length > 0
      if _.isString gbspec[0]
        gg.xform.Split.byColNames name, gbspec
      else:
        throw Error("Faceting by transformations not implemented yet")
    # TODO: also support varying run-time parameters


  @byColValues: (name, col) ->
    gg.xform.Split.byFunction name, (row) -> row.get(col)

  # Partition by using a function
  @byFunction: (name, f) ->
    new gg.wf.Partition
      f: f
      name: name

  # equivalent to creating a new column called @name
  # a poor man's unfold (or fold?)
  #
  # Example table:
  #
  #   a b c
  #   1 2 3
  #   4 5 6
  #
  # byColNames(d, [b,c]) creates two tables
  #
  #   a b c d
  #   1 2 3 2
  #   4 5 6 5
  #
  # and
  #
  #   a b c d
  #   1 2 3 3
  #   4 5 6 6
  #
  @byColNames: (name, cols) ->
    throw Error() unless cols.length == 0 or _.isString cols[0]

    f = (table) ->
      _.map cols, (col) ->
        newtable = table.cloneDeep()
        newtable.addColumn name, table.getColumn(col)
        {key: col, table: newtable}

    new gg.wf.Split
      f: f
      name: name


