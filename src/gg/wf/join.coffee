#<< gg/wf/node




# Opposite of Split
# XXX: Not really used. see gg.wf.label instead
#
# Does not compute anything
class gg.wf.Join extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    @envkey = @spec.key or @spec.envkey
    @attr = @spec.attr or @envkey
    @default = @spec.default
    @type = "join"
    @name = _.findGood [@spec.name, "join-#{@id}"]

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


  ready: -> super

  # pop from each env's keys list
  run: ->
    unless @ready()
      throw Error("#{@name} not ready: #{@inputs.length} of #{@children().length} inputs")

    tables = _.map @inputs, (data) =>
      table = data.table
      val = data.env.group @envkey, @default
      table.addConstColumn @attr, val
      table

    env = @inputs[0].env.clone()
    output = gg.data.Table.merge _.values(tables)
    @output 0, new gg.wf.Data output, env

    output


