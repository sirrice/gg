#<< gg/wf/node

class gg.wf.Stdout extends gg.wf.Exec
  constructor: (@spec={}) ->
    super
    @type = "stdout"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]

    @params.ensureAll
      n: [ [], null ]
      aess: [ [], null ]
    @log = gg.util.Log.logger "StdOut: #{@name}-#{@id}"

  compute: (table, env, params) ->
    console.log @
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
  constructor: (@spec={}) ->
    super
    @type = "scaleout"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]

    unless @params.contains 'scales'
      throw Error('scales was not passed in')
    @dlog = gg.util.Log.logger "ScaleOut: #{@name}", gg.util.Log.DEBUG

  compute: (table, env, params) ->
    gg.wf.Scales.print params.get('scales'), @dlog
    table

  @print: (scales, log=null) ->
    log = gg.util.Log.logger("scaleout") unless log?
    _.each scales.scalesList[0..2], (scales, idx) =>
      log "Out: scales #{scales.id}, #{scales.scales}"
      _.each scales.scalesList(), (scale) =>
        aes = scale.aes
        str = scale.toString()
        type = scale.type
        log "Out: layer#{idx},scaleId#{scale.id} #{type}\t#{str}"



