
# An aggregate, by default, acts upon the 'y' attribute.
class gg.xform.Aggregate
  @ggpackage = "gg.xform.Aggregate"

  constructor: (@spec) ->
    @type = gg.data.Schema.numeric
    @args = @spec.args
    @log = gg.util.Log.logger @constructor.ggpackage, "Agg"

  reset: ->
  update: (row) -> throw Error("update not implemented")
  value: -> null

  compute: (table) ->
    @reset()
    table.each (row) => @update row
    @value()

  # spec is a agg type or
  #
  # { 
  #   type: 
  #   arg|args: STRING | [ STRING* ]
  # }
  #
  @fromSpec: (spec) ->
    # clean up the spec
    spec = { type: spec } if _.isString spec
    type = spec.type
    args = spec.arg or spec.args or 'y'
    args = _.flatten [args]

    klass = {
      count: gg.xform.Count
      sum: gg.xform.Sum
      avg: gg.xform.Avg
    }[type] or gg.xform.Count

    spec = 
      type: type
      args: args

    new klass spec


        
class gg.xform.Count extends gg.xform.Aggregate
  @ggpackage = "gg.xform.Count"

  constructor: (@name="count") ->
    super

    @arg = @args[0]
    @val = null

  reset: -> @val = 0
  update: (row) -> 
    #if _.isNumber row.get @arg
    @val += 1
  value: -> @val

  compute: (table) -> @val = table.rows.length
 
class gg.xform.Sum extends gg.xform.Aggregate
  @ggpackage = "gg.xform.Sum"

  constructor: (@name="sum") ->
    super
    @arg = @args[0]
    @val = null

  reset: -> @val = 0
  update: (row) -> @val += (row.get @arg or 0)
  value: -> @val

class gg.xform.Avg extends gg.xform.Aggregate
  @ggpackage = "gg.xform.Avg"

  constructor: (@name="avg") ->
    super
    @arg = @args[0]
    @sum = null
    @count = null

  reset: -> 
    @sum = 0
    @count = 0

  update: (row) -> 
    if _.isNumber row.get @arg
      @sum += row.get @arg
      @count += 1

  value: -> @sum / @count





