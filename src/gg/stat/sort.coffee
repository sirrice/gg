#<< gg/stat/stat

# TODO: the proper API given array types
class gg.stat.SortStat extends gg.stat.Stat
  @aliases = ['sort', 'sorted']

  parseSpec: ->
    attrs = ["col", "cols", "attr", "attrs", "aes", "aess" ]
    @attrs = _.findGoodAttr @spec, attrs, []
    @attrs = [@attrs] unless _.isArray @attrs
    @reverse = _.findGood [@spec.reverse, @spec.invert, false]
    super

  inputSchema: (table, env, node) -> @attrs


  compute: (table, env, node) ->
    f = (attr) ->
      table.contains(attr) and not table.schema.inArray(attr)
    attrs = @attrs.filter f
    reverse = @reverse

    if attrs.length > 0
      cmp = (row1, row2) ->
        for attr in attrs
          if row1.get(attr) > row2.get(attr)
            return if reverse then -1 else 1
          else if row1.get(attr) < row2.get(attr)
            return if reverse then 1 else -1
        0
      table.sort cmp

    table



