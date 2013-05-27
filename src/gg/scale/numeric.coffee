#<< gg/scale/scale
#<< gg/data/schema


class gg.scale.Linear extends gg.scale.Scale
  @aliases = "linear"
  constructor: (@spec) ->
    @d3Scale = d3.scale.linear()
    @type = gg.data.Schema.numeric
    super


class gg.scale.Time extends gg.scale.Scale
  @aliases = "time"
  constructor: (@spec) ->
      @d3Scale = d3.time.scale()
      @type = gg.data.Schema.date
      super

class gg.scale.Log extends gg.scale.Scale
  @aliases = "log"
  constructor: (@spec) ->
      @d3Scale = d3.scale.log()
      @type = gg.data.Schema.numeric
      super

  valid: (v) ->
    v != 0 and super v

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

  mergeDomain: (domain) ->
    md = @domain()
    unless @domainSet
      if @domainUpdated and md? and md.length == 2
        if _.isNaN(domain[0]) or _.isNaN(domain[1])
          throw Error("domain is invalid: #{domain}")

        newDomain = [
          Math.min md[0], domain[0]
          Math.max md[1], domain[1]
        ]
        if newDomain[0] < 0 and newDomain[1] > 0
          @log.warn "domain maximum (#{newDomain}) truncated to 0"
        @domain newDomain
      else
        @domain domain


  scale: (v) -> if v is 0 then -1 else @d3Scale(v)


