#<< gg/wf/node

class gg.wf.EnvPut extends gg.wf.Node
  constructor: ->
    super
    @type = "label"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]
    @log = gg.util.Log.logger @name


    # data is a mapping of key -> val where
    # key:  label name in environment
    # val:  label value or a function with signature
    #       (table, env) -> value
    #
    # note: if function, it will be evaluated when the key
    #       is accessed
    @params.ensure 'pairs', [], {}

  run: ->
    throw Error("#{@name}: node not ready") unless @ready()

    params = @params
    table = @inputs[0].table
    env = @inputs[0].env
    newenv = env.clone()
    _.each params.get('pairs'), (val, key) ->
      newenv.put key, val

    @output 0, new gg.wf.Data(table, newenv)
    table


#
# Copy a key from the environment into a column in table
# Abstractly:
#
#   table.addColumn attr, env.get(key)
#
# used to bring group-by attributes back into table
#
# spec.envkey  label name e.g., "layerIdx"
# spec.attr    new table attribute's name e.g., "fill"
# spec.default value if envkey not found.
#              set to null if don't add if envkey not found.
#
class gg.wf.EnvGet extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec
    @type = "envget"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]

    @params.ensureAll
      envkey: [ ['key', 'envkey'] ]
      attr: ['attr', 'key', 'envkey']
      default: [[], null]

    unless @params.get('envkey')?
      throw Error("#{@name}: Need label key and value/value function)")

  run: ->
    throw Error("#{@name}: node not ready") unless @ready()

    data = @inputs[0]
    table = data.table.clone()

    envkey = @params.get 'envkey'
    defaultVal = @params.get 'default'
    attr = @params.get 'attr'

    unless envkey? and data.env.contains envkey
      @output 0, @inputs[0]
      return

    val = data.env.get envkey, defaultVal
    table.addConstColumn attr, val

    @output 0, new gg.wf.Data table, data.env.clone()
    table


