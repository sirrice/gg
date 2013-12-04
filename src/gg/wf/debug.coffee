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
    mdcols = ['layer', 'facet-x', 'facet-y', 'group', 'lc']
    if @log.level >= ggutil.Log.lookupLevel(@log.logname)
      gg.wf.Stdout.print pairtable.left(), params.get('cols'), params.get('n'), @log
      gg.wf.Stdout.print pairtable.right(), mdcols, params.get('n'), @log
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
    table.each (row, idx) ->
      if (idx % blockSize) == 0
        pairs = _.map cols, (col) -> [col, row.get(col)]
        log JSON.stringify(pairs)

  @printTables: (args...) -> @print args...





class gg.wf.Scales extends gg.wf.SyncBlock
  @ggpackage = "gg.wf.Scales"
  @type = "scaleout"
  @log = gg.util.Log.logger @ggpackage, "scalesout"

  constructor: (@spec) ->
    super
    @log = gg.util.Log.logger @constructor.ggpackage, "Scales: #{@name}-#{@id}"

  parseSpec: ->
    super
    @params.ensureAll
      key: [ [], _.flatten [gg.facet.base.Facets.facetKeys, 'layer'] ]

  compute: (pairtable, params) ->
    md = pairtable.right()
    if @log.level >= ggutil.Log.lookupLevel(@log.logname)
      md.each (row) =>
        layer = row.get 'layer'
        scale = row.get 'scales'
        gg.wf.Scales.print scale, layer, @log
    pairtable

  @print: (scaleset, layerIdx, log=null) ->
    log ?= @log 

    log "scaleset #{scaleset.id}, #{scaleset.scales}"
    _.each scaleset.all(), (scale) ->
      log "#{scaleset.id} l(#{layerIdx}) t(#{scale.type})\t#{scale.toString()}"



