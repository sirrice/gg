#<< gg/wf/node

class gg.wf.Stdout extends gg.wf.Exec
  @ggpackage = "gg.wf.Stdout"
  @type = "stdout"

  constructor: (@spec) ->
    super

    @log = gg.util.Log.logger @constructor.ggpackage, "StdOut: #{@name}-#{@id}"

  parseSpec: ->
    @params.ensureAll
      n: [ [], null ]
      aess: [ [], null ]

  compute: (data, params) ->
    env = data.env
    @log "facetX: #{env.get("facetX")}\tfacetY: #{env.get("facetY")}"
    gg.wf.Stdout.print data.table, params.get('aess'), params.get('n'), @log
    data

  @print: (table, aess, n, log=null) ->
    if _.isArray table
      _.each table, (t) -> gg.wf.Stdout.print t, aess, n, log

    log = gg.util.Log.logger(gg.wf.Stdout.ggpackage, "stdout") unless log?
    n = if n? then n else table.nrows()
    blockSize = Math.max(Math.floor(table.nrows() / n), 1)
    idx = 0
    schema = table.schema
    if aess?
      aess = aess.filter (aes) -> schema.contains aes
    log "# rows: #{table.nrows()}"
    log "Schema: #{schema.toSimpleString()}"
    while idx < table.nrows()
      row = table.get(idx)
      row = row.project aess if aess?
      log row.toString()
      idx += blockSize

  @printTables: (args...) -> @print args...





class gg.wf.Scales extends gg.wf.Exec
  @ggpackage = "gg.wf.Scales"
  @type = "scaleout"

  constructor: (@spec) ->
    super

    @log = gg.util.Log.logger @constructor.ggpackage, "Scales: #{@name}-#{@id}"

  compute: (data, params) ->
    layerIdx = data.env.get 'layer'
    gg.wf.Scales.print data.env.get('scales'), layerIdx,  @log
    data

  # @param scales set
  @print: (scaleset, layerIdx, log=null) ->
    log = gg.util.Log.logger("scaleout") unless log?

    log "scaleset #{scaleset.id}, #{scaleset.scales}"
    _.each scaleset.scalesList(), (scale) =>
      str = scale.toString()
      log "layer #{layerIdx}, #{str}"



