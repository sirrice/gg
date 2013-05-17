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
    n = if @n? then @n else table.nrows()
    blockSize = Math.max(Math.floor(table.nrows() / n), 1)
    idx = 0
    schema = table.schema
    arr = _.map schema.attrs(), (attr) ->
      "\t#{attr}(#{schema.type(attr)})"
    @dlog "Number of rows: #{table.nrows()}"
    @dlog "Schema: #{arr.join "\t"}"
    while idx < table.nrows()
      row = table.get(idx)
      row = row.project @aess if @aess?
      raw = _.clone row.raw()
      _.each raw, (v, k) ->
        raw[k] = v[0..4] if _.isArray v
      @dlog JSON.stringify raw
      idx += blockSize
    table



class gg.wf.Scales extends gg.wf.Exec
  constructor: (@spec={}) ->
    super @spec

    @type = "scaleout"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]
    @scales = @spec.scales
    @dlog = gg.util.Log.logger "ScaleOut: #{@name}", gg.util.Log.DEBUG

  compute: (table, env, node) ->
    _.each @scales.scalesList[0..2], (scales, idx) =>
      @dlog "Out: scales #{scales.id}, #{scales.scales}"
      _.each scales.scalesList(), (scale) =>
        aes = scale.aes
        str = scale.toString()
        type = scale.type
        @dlog "Out: layer#{idx},scaleId#{scale.id} #{type}\t#{str}"
    table




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

