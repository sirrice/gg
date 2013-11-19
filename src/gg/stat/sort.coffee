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
    table = pairtable.left()
    reverse = params.get 'reverse'
    attrs = params.get 'attrs'
    attrs = attrs.filter (attr) -> table.has(attr)
    table = table.orderby attrs, reverse
    pairtable.left table
    pairtable
