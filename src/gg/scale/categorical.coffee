#<< gg/scale/scale
#<< gg/data/schema

class gg.scale.BaseCategorical extends gg.scale.Scale

  # subclasses are responsible for instantiating @d3Scale and @invertScale
  constructor: (@padding=.05) ->
    @type = gg.data.Schema.ordinal
    @d3Scale = d3.scale.ordinal()
    @invertScale = d3.scale.ordinal()
    super

  @defaultDomain: (col) ->
      vals = _.uniq _.flatten(col)
      vals.sort (a,b)->a-b
      vals

  clone: ->
    ret = super
    ret.invertScale = @invertScale.copy()
    ret

  defaultDomain: (col) -> gg.scale.BaseCategorical.defaultDomain col

  mergeDomain: (domain) ->
    newDomain = _.uniq(_.union domain, @domain())
    #console.log "#{@constructor.name}-#{@type} merging #{newDomain}"
    @domain newDomain

  domain: (interval) ->
    if interval?
      @invertScale.range interval
    super

  d3Range: ->
    range = @d3Scale.range()
    rangeBand = @d3Scale.rangeBand()
    range = _.map range, (v) -> v + rangeBand/2.0
    range

  range: (interval) ->
    if interval? and not @rangeSet
      @d3Scale.rangeBands interval#, @padding
      @invertScale.domain @d3Range()
    @d3Range()

  resetDomain: ->
    @domainUpdated = false
    @domain([])
    @invertScale.domain []

  invert: (v) -> @invertScale v


