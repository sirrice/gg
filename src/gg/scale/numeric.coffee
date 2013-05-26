#<< gg/scale/scale
#<< gg/data/schema


class gg.scale.Linear extends gg.scale.Scale
  @aliases = "linear"
  constructor: () ->
    @d3Scale = d3.scale.linear()
    @type = gg.data.Schema.numeric
    super


class gg.scale.Time extends gg.scale.Scale
  @aliases = "time"
  constructor: () ->
      @d3Scale = d3.time.scale()
      @type = gg.data.Schema.date
      super

class gg.scale.Log extends gg.scale.Scale
  @aliases = "log"
  constructor: () ->
      @d3Scale = d3.scale.log()
      @type = gg.data.Schema.numeric
      super

  valid: (v) -> v > 0

  defaultDomain: (col) ->
    col = _.filter col, (v) -> v > 0
    if col.length is 0
      return [1, 10]

    @min = _.mmin col
    @max = _.mmax col

    if @center?
        extreme = Math.max @max-@center, Math.abs(@min-@center)
        interval = [@center - extreme, @center + extreme]
    else
        interval = [@min, @max]

    interval

  scale: (v) -> if v is 0 then -1 else @d3Scale(v)


