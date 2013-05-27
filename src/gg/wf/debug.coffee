#<< gg/wf/node

class gg.wf.Stdout extends gg.wf.Exec
  constructor: (@spec={}) ->
    super @spec

    @type = "stdout"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]
    @n = _.findGood [@spec.n, null]
    @aess = @spec.aess or null
    @dlog = gg.util.Log.logger "StdOut: #{@name}-#{@id}"

  compute: (table, env, node) ->
    @dlog "facetX: #{env.get("facetX")}\tfacetY: #{env.get("facetY")}"
    gg.wf.Stdout.print table, @aess, @n, @dlog
    table

  @print: (table, aess, n, log=null) ->
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

  @printTables: (tables, aess, n, log=null) ->
    _.each tables, (table) ->
      gg.wf.Stdout.print table, aess, n, log





class gg.wf.Scales extends gg.wf.Exec
  constructor: (@spec={}) ->
    super @spec

    @type = "scaleout"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]
    @scales = @spec.scales
    @dlog = gg.util.Log.logger "ScaleOut: #{@name}", gg.util.Log.DEBUG

  compute: (table, env, node) ->
    gg.wf.Scales.print @scales, @dlog
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




###
gg.wf.Stdout = gg.wf.Node.klassFromSpec
  type: "stdout"
  f: (table, env, node) ->
    table.each (row, idx) =>
      if @n is null or idx < @n
        str = JSON.stringify(_.omit(row, ['get', 'ncols']))
        @log "Stdout: #{str}"
    table





gg.wf.Scales = gg.wf.Node.klassFromSpec
  type: "scaleout"
  f: (table, env, node) ->
    scales = @scales.scalesList[0]
    _.each scales.aesthetics(), (aes) =>
      str = scales.scale(aes).toString()
      @log "ScaleOut: #{str}"
    table

###

