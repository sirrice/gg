#<< gg/stat/stat

# TODO: the proper API given array types
class gg.stat.Sort extends gg.stat.Stat
  @ggpackage = "gg.stat.Sort"
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

  inputSchema: (pairtable, params) -> params.get 'attrs'


  compute: (pairtable, params) ->
    table = pairtable.getTable()
    reverse = params.get 'reverse'
    attrs = params.get 'attrs'
    attrs = attrs.filter (attr) -> table.has(attr)
    reverse = if reverse then -1 else 1

    if attrs.length > 0
      cmp = (row1, row2) ->
        for attr in attrs
          v1 = row1[attr]
          v2 = row2[attr]
          unless v1? and v2?
            if v1?
              return -1 * reverse
            else
              return 1 * reverse
          if v1 > v2
            return 1 * reverse
          else if v1 < v2
            return -1 * reverse
        0
      raws = table.raw() 
      raws.sort cmp

    table = gg.data.Table.fromArray raws
    new gg.data.PairTable table, pairtable.getMD()


