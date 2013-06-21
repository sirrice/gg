#<< gg/wf/node




# Opposite of Split
# XXX: Not really used. see gg.wf.label instead
#
# Does not compute anything
class gg.wf.Join extends gg.wf.Node
  @ggpackage = "gg.wf.Join"

  constructor: (@spec={}) ->
    super @spec
    @type = "join"
    @name = _.findGood [@spec.name, "join-#{@id}"]

    @params.ensureAll
      envkey: ['key', 'envkey']
      attr: ['attr', 'key', 'envkey']
      default: ['default']

  addInputPort: ->
    @inputs.push null
    cb = @getAddInputCB @inputs.length-1
    @log.warn "#{@name}-#{@id} addInputPort: #{cb.port}"
    cb

  cloneSubplan: (parent, parentPort, stop) ->

    if @ is stop
      [clone, clonecb] = [@, @addInputPort()]
      @log.warn "cloneSubplan: #{parent.name}-#{parent.id}(#{parentPort}) -> me(#{clonecb.port} -> stop)"
      [clone, clonecb]
    else
      super parent, parentPort, stop

  compute: (tables, envs, params) ->
    envkey = @params.get 'envkey'
    defaultVal = @params.get 'default'
    attr = @params.get 'attr'

    _.times tables.length, (idx) ->
      table = tables[idx]
      env = envs[idx]
      val =
        if env.contains(envkey)
          env.get(envkey)
        else
          defaultVal

      if table.contains attr
        if table.schema.isArray attr
          # XXX: attr better not be an array type!
          throw Error("Join doesn't support setting array types")
        table.each (row) -> row.set attr, val
      else
        table.addConstColumn attr, val

    gg.data.Table.merge tables


  run: ->
    unless @ready()
      throw Error("#{@name} not ready: #{@inputs.length} of #{@children().length} inputs")

    tables = _.pick @inputs, 'table'
    envs = _.pick @inputs, 'env'

    table = @compute tables, envs, params
    env = _.first(envs).clone()
    data = new gg.wf.Data table, env

    @output 0, data
    output


