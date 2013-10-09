#<< gg/wf/node

class gg.wf.Stdout extends gg.wf.Exec
  @ggpackage = "gg.wf.Stdout"
  @type = "stdout"

  constructor: (@spec) ->
    super
    @log = gg.util.Log.logger @constructor.ggpackage, "StdOut: #{@name}-#{@id}"

  parseSpec: ->
    @params.ensureAll
      key: [ [], _.flatten [gg.facet.base.Facets.facetKeys, 'layer'] ]
      n: [ [], null ]
      aess: [ [], null ]

  compute: (pairtable, params, cb) ->
    md = pairtable.getMD()
    gg.wf.Stdout.print pairtable.getTable(), params.get('aess'), params.get('n'), @log
    cb null, pairtable


  @print: (table, aess, n, log=null) ->
    if _.isArray table
      _.each table, (t) -> gg.wf.Stdout.print t, aess, n, log

    log = gg.util.Log.logger(gg.wf.Stdout.ggpackage, "stdout") unless log?
    idx = 0
    n = if n? then n else table.nrows()
    blockSize = Math.max(Math.floor(table.nrows() / n), 1)
    schema = table.schema
    if aess?
      aess = aess.filter (aes) -> schema.contains aes

    log "# rows: #{table.nrows()}"
    log "Schema: #{schema.toString()}"
    while idx < table.nrows()
      row = table.get idx
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

  parseSpec: ->
    @params.ensureAll
      key: [ [], _.flatten [gg.facet.base.Facets.facetKeys, 'layer'] ]


  compute: (pairtable, params, cb) ->
    md = pairtable.getMD()
    md.each (row) ->
      layer = row.get 'layer'
      scale = row.get 'scales'
      gg.wf.Scales.print scale, layer, @log
    cb null, pairtable

  @print: (scaleset, layerIdx, log=null) ->
    log = gg.util.Log.logger("scaleout") unless log?

    log "scaleset #{scaleset.id}, #{scaleset.scales}"
    _.each scaleset.scalesList(), (scale) =>
      str = scale.toString()
      log "layer #{layerIdx}, #{str}"



