
# An aggregate, by default, acts upon the 'y' attribute.
class gg.xform.Aggregate
  @ggpackage = "gg.xform.Aggregate"

  constructor: (@spec) ->
    @type = gg.data.Schema.numeric
    @args = @spec.args
    @params = new gg.util.Params @spec.params
    @log = gg.util.Log.logger @constructor.ggpackage, "Agg"

  reset: ->
  update: (row) -> throw Error("update not implemented")
  value: -> null

  compute: (table) ->
    @reset()
    table.fastEach (row) => @update row
    @value()

  # spec is a agg type or
  #
  # { 
  #   type: 
  #   arg|args: STRING | [ STRING* ]
  #   params: {}
  # }
  #
  @fromSpec: (spec) ->
    # clean up the spec
    spec = { type: spec } if _.isString spec
    type = spec.type
    args = spec.arg or spec.args or 'y'
    args = _.flatten [args]
    params = spec.params or {}

    klass = {
      count: gg.xform.Count
      sum: gg.xform.Sum
      avg: gg.xform.Avg
      quantile: gg.xform.Quantile
      min: gg.xform.Min
      max: gg.xform.Max
    }[type] or gg.xform.Count

    spec = 
      type: type
      args: args
      params: params

    new klass spec


        
class gg.xform.Count extends gg.xform.Aggregate
  @ggpackage = "gg.xform.Count"

  constructor: (@spec, @name="count") ->
    super

    @arg = @args[0]
    @val = null

  reset: -> @val = 0
  # TODO: differentiate non-numeric (nan) from numeric
  update: (row) -> 
    #if _.isNumber row.get @arg
    @val += 1
  value: -> @val

  compute: (table) -> @val = table.rows.length
 
class gg.xform.Sum extends gg.xform.Aggregate
  @ggpackage = "gg.xform.Sum"

  constructor: (@spec, @name="sum") ->
    super
    @arg = @args[0]
    @val = null

  reset: -> @val = 0
  update: (row) -> 
    @val += (row.get(@arg) or 0)
  value: -> @val

class gg.xform.Avg extends gg.xform.Aggregate
  @ggpackage = "gg.xform.Avg"

  constructor: (@spec, @name="avg") ->
    super
    @arg = @args[0]
    @sum = null
    @count = null

  reset: -> 
    @sum = 0
    @count = 0

  # TODO: remember nulls
  update: (row) -> 
    y = row.get @arg
    if _.isNumber(y) and _.isFinite(y)
      @sum += y
      @count += 1

  value: -> @sum / @count

class gg.xform.Max extends gg.xform.Aggregate
  @ggpackage = "gg.xform.Max"

  constructor: (@spec, @name="max") ->
    super
    @arg = @args[0]
    @v = null

  reset: -> @v = null

  # TODO: remember nulls
  update: (row) -> 
    y = row.get @arg
    if _.isNumber(y) and _.isFinite(y)
      @v ?= y
      @v = Math.max(@v, y)

  value: -> @v



class gg.xform.Min extends gg.xform.Aggregate
  @ggpackage = "gg.xform.Min"

  constructor: (@spec, @name="min") ->
    super
    @arg = @args[0]
    @v = null

  reset: -> @v = null

  # TODO: remember nulls
  update: (row) -> 
    y = row.get @arg
    if _.isNumber(y) and _.isFinite(y)
      @v ?= y
      @v = Math.min(@v, y)

  value: -> @v




class gg.xform.Quantile extends gg.xform.Aggregate
  @ggpackage = "gg.xform.Quartile"

  constructor: (@spec, @name="quantile") ->
    super
    @arg = @args[0]
    @vals = []
    @k = @params.get('k')

  reset: -> 
    @vals = []

  # TODO: remember nulls
  update: (row) -> 
    y = row.get @arg
    if _.isNumber(y) and _.isFinite(y)
      @vals.push row.get(@arg)

  value: -> 
    @vals.sort d3.ascending
    d3.quantile @vals, @k






