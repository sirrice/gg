#<< gg/wf/node




# Opposite of Split
# XXX: Not really used. see gg.wf.label instead
#
# Does not compute anything
class gg.wf.Join extends gg.wf.Node
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


  # pop from each env's keys list
  run: ->
    unless @ready()
      throw Error("#{@name} not ready: #{@inputs.length} of #{@children().length} inputs")

    envkey = @params.get 'envkey'
    defaultVal = @params.get 'default'
    attr = @params.get 'attr'

    tables = _.map @inputs, (data) =>
      table = data.table
      val = data.env.get envkey, defaultVal
      table.addConstColumn attr, val
      table

    env = @inputs[0].env.clone()
    output = gg.data.Table.merge _.values(tables)
    @output 0, new gg.wf.Data output, env

    output


