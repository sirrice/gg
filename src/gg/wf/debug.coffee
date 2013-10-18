#<< gg/wf/node
#<< gg/wf/block

class gg.wf.Stdout extends gg.wf.SyncBlock
  @ggpackage = "gg.wf.Stdout"
  @type = "stdout"

  constructor: (@spec) ->
    super
    @log = gg.util.Log.logger @constructor.ggpackage, "StdOut: #{@name}-#{@id}"

  parseSpec: ->
    super
    @params.ensureAll
      key: [ [], _.flatten [gg.facet.base.Facets.facetKeys, 'layer'] ]
      n: [ [], null ]
      cols: [ ['aess'], null ]

  compute: (pairtable, params) ->
    mdcols = ['layer', 'facet-x', 'facet-y', 'scales', 'lc']
    gg.wf.Stdout.print pairtable.getTable(), params.get('cols'), params.get('n'), @log
    gg.wf.Stdout.print pairtable.getMD(), mdcols, params.get('n'), @log
    pairtable


  @print: (table, cols, n, log=null) ->
    if _.isArray table
      _.each table, (t) -> gg.wf.Stdout.print t, cols, n, log

    idx = 0
    n = if n? then n else table.nrows()
    blockSize = Math.max(Math.floor(table.nrows() / n), 1)
    schema = table.schema
    cols ?= schema.cols
    log ?= gg.util.Log.logger gg.wf.Stdout.ggpackage, "stdout" 

    log "# rows: #{table.nrows()}"
    log "Schema: #{schema.toString()}"
    while idx < table.nrows()
      row = table.get idx
      pairs = _.map cols, (col) -> [col, row.get(col)]
      log JSON.stringify(pairs)
      idx += blockSize

  @printTables: (args...) -> @print args...





class gg.wf.Scales extends gg.wf.SyncBlock
  @ggpackage = "gg.wf.Scales"
  @type = "scaleout"

  constructor: (@spec) ->
    super
    @log = gg.util.Log.logger @constructor.ggpackage, "Scales: #{@name}-#{@id}"

  parseSpec: ->
    super
    @params.ensureAll
      key: [ [], _.flatten [gg.facet.base.Facets.facetKeys, 'layer'] ]


  compute: (pairtable, params) ->
    md = pairtable.getMD()
    md.each (row) ->
      layer = row.get 'layer'
      scale = row.get 'scales'
      gg.wf.Scales.print scale, layer, @log
    pairtable

  @print: (scaleset, layerIdx, log=null) ->
    log = gg.util.Log.logger("scaleout") unless log?

    log "scaleset #{scaleset.id}, #{scaleset.scales}"
    _.each scaleset.scalesList(), (scale) =>
      str = scale.toString()
      log "layer #{layerIdx}, #{str}"



