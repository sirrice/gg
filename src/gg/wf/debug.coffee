#<< gg/wf/node

class gg.wf.Stdout extends gg.wf.Exec
  @ggpackage = "gg.wf.Stdout"

  constructor: (@spec={}) ->
    super
    @type = "stdout"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]

    @params.ensureAll
      n: [ [], null ]
      aess: [ [], null ]
    @log = gg.util.Log.logger "StdOut: #{@name}-#{@id}"

  compute: (table, env, params) ->
    @log "facetX: #{env.get("facetX")}\tfacetY: #{env.get("facetY")}"
    gg.wf.Stdout.print table, params.get('aess'), params.get('n'), @log
    table

  @print: (table, aess, n, log=null) ->
    if _.isArray table
      _.each table, (t) -> gg.wf.Stdout.print t, aess, n, log

    log = gg.util.Log.logger("stdout") unless log?
    n = if n? then n else table.nrows()
    blockSize = Math.max(Math.floor(table.nrows() / n), 1)
    idx = 0
    schema = table.schema
    log "# rows: #{table.nrows()}"
    log "Schema: #{schema.toSimpleString()}"
    while idx < table.nrows()
      row = table.get(idx)
      row = row.project aess if aess?
      raw = row.clone().raw()
      _.each raw, (v, k) ->
        raw[k] = v[0..4] if _.isArray v

      log JSON.stringify raw
      idx += blockSize

  @printTables: (args...) -> @print args...





class gg.wf.Scales extends gg.wf.Exec
  @ggpackage = "gg.wf.Scales"
  constructor: (@spec={}) ->
    super
    @type = "scaleout"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]

    @dlog = gg.util.Log.logger "ScaleOut: #{@name}", gg.util.Log.DEBUG

  compute: (table, env, params) ->
    layerIdx = env.get 'layer'
    gg.wf.Scales.print env.get('scales'), layerIdx,  @dlog
    table

  # @param scales set
  @print: (scaleset, layerIdx, log=null) ->
    log = gg.util.Log.logger("scaleout") unless log?

    log "Out: scaleset #{scaleset.id}, #{scaleset.scales}"
    _.each scaleset.scalesList(), (scale) =>
      str = scale.toString()
      log "Out: layer #{layerIdx}, #{str}"



