#<< gg/scale/scale
#<< gg/data/schema

class gg.scale.BaseCategorical extends gg.scale.Scale

  # subclasses are responsible for instantiating @d3Scale and @invertScale
  constructor: (@spec) ->
    @type = gg.data.Schema.ordinal
    @d3Scale = d3.scale.ordinal()
    @invertScale = d3.scale.ordinal()
    super

  @defaultDomain: (col) ->
      vals = _.uniq _.flatten(col)
      # XXX: this is not useful and prevents data sorting
      #vals.sort (a,b)->a-b
      vals

  clone: ->
    ret = super
    ret.invertScale = @invertScale.copy()
    ret

  defaultDomain: (col) -> gg.scale.BaseCategorical.defaultDomain col

  mergeDomain: (domain) ->
    domain = [] unless domain?
    newDomain = _.uniq domain.concat(@domain())
    #newDomain = newDomain.sort()
    @domain newDomain

  domain: (interval) ->
    if interval?
      @invertScale.range interval
    super

  d3Range: ->
    range = @d3Scale.range()
    if @type == gg.data.Schema.numeric
      rangeBand = @d3Scale.rangeBand()
      range = _.map range, (v) -> v + rangeBand/2.0
    range

  range: (interval) ->
    if interval? and not @rangeSet
      if @type == gg.data.Schema.numeric
        @d3Scale.rangeBands interval#, @padding
      else
        #@d3Scale.range interval
        @d3Scale.rangeBands interval
      @invertScale.domain @d3Range()
    @d3Range()

  resetDomain: ->
    @domainUpdated = false
    @domain([])
    @invertScale.domain []

  invert: (v) -> @invertScale v

  valid: (v) -> v in @domain()


