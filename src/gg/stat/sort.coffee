#<< gg/stat/stat

# TODO: the proper API given array types
class gg.stat.SortStat extends gg.stat.Stat
  @ggpackage = "gg.stat.SortStat"
  @aliases = ['sort', 'sorted']

  parseSpec: ->
    super
    attrs = ["col", "cols", "attr", "attrs", "aes", "aess" ]
    attrs = _.findGoodAttr @spec, attrs, []
    attrs = [attrs] unless _.isArray attrs
    reverse = _.findGood [@spec.reverse, @spec.invert, false]
    @params.putAll
      attrs: attrs
      reverse: reverse

  inputSchema: (data, params) -> params.get 'attrs'


  compute: (data, params) ->
    table = data.table
    env = data.env
    f = (attr) ->
      table.contains(attr) and not table.schema.inArray(attr)
    attrs = params.get 'attrs'
    attrs = attrs.filter f
    reverse = params.get 'reverse'

    if attrs.length > 0
      cmp = (row1, row2) ->
        for attr in attrs
          if row1.get(attr) > row2.get(attr)
            return if reverse then -1 else 1
          else if row1.get(attr) < row2.get(attr)
            return if reverse then 1 else -1
        0
      table.sort cmp

    data


