#<< gg/wf/node

class gg.wf.EnvPut extends gg.wf.Exec
  @ggpackage = "gg.wf.EnvPut"
  @type = "envput"


  parseSpec: ->
    # data is a mapping of key -> val where
    # key:  label name in environment
    # val:  label value or a function with signature
    #       (table, env) -> value
    #
    # note: if function, it will be evaluated when the key
    #       is accessed
    @params.ensure 'pairs', [], {}

  compute: (table, env, params) ->
    _.each params.get('pairs'), (val, key) =>
      @log "envput: #{key} -> #{val}"
      env.put key, val
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
class gg.wf.EnvGet extends gg.wf.Exec
  @ggpackage = "gg.wf.EnvGet"
  @type = "envget"

  parseSpec: ->
    @params.ensureAll
      envkey: [ ['key', 'envkey'] ]
      attr: ['attr', 'key', 'envkey']
      default: [[], null]

    unless @params.get('envkey')?
      throw Error("#{@name}: Need label key and value/value function)")

  compute: (table, env, params) ->
    envkey = params.get 'envkey'
    defaultVal = params.get 'default'
    attr = params.get 'attr'

    if envkey? and env.contains envkey
      val = defaultVal
      val = env.get(envkey) if env.contains(envkey)
      table.addConstColumn attr, val

    table


