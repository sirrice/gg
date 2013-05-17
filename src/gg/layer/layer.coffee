#<< gg/util/util


class gg.layer.Layer
  constructor: (@g, @spec={}) ->
    # which index in the specification
    @layerIdx = @spec.layerIdx if @spec.layerIdx?
    @type = "layer"
    @name = _.findGood [@spec.name, "node-#{@id}"]

    @log = gg.util.Log.logger "Layer-#{@layerIdx}"

    @parseSpec()
  @id: -> gg.wf.Node::_id += 1
  _id: 0


  parseSpec: -> null

  @fromSpec: (g, spec) ->
    if _.isArray spec
      throw Error("layer currently only supports shorthand style")
      new gg.layer.Array g, spec
    else
      new gg.layer.Shorthand g, spec



