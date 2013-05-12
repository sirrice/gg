#<< gg/wf/node
#
#
# Add group pair into the environment.  Abstractly:
#
#   env.push {key: val}
#
# used by first xform in layer to name the rest of the workflow
#
# spec.key  label name e.g., "layer"
# spec.val  label value e.g., "layer-2"
#           also: spec.value
# spec.f    function to dynamically compute label value
#
class gg.wf.Label extends gg.wf.Node
  constructor: (@spec={}) ->
    super @spec

    @key = @spec.key
    @compute = _.findGood [@spec.val, @spec.value, @spec.f, null]
    @type = "label"
    @name = _.findGood [@spec.name, "#{@type}-#{@id}"]
    unless @key?
      throw Error("#{@name}: Did not define a label key and value/value function)")

  run: ->
    throw Error("#{@name}: node not ready") unless @ready()

    data = @inputs[0]
    if _.isFunction @compute
      val = @compute data.table, data.env, @
    else
      val = @compute

    console.log "#{@name}: adding label #{@key} -> #{val}"

    env = data.env.clone()
    env.pushGroupPair @key, val
    @output 0, new gg.wf.Data(data.table, env)
    data.table



