#<< gg/wf/node


# Creates a clone of its inputs for each child
#
# NOTE: ONLY workflow node with multiple children
#
class gg.wf.Multicast extends gg.wf.Node
  @ggpackage = "gg.wf.Multicast"

  constructor: (@spec={}) ->
    super @spec

    @type = "multicast"
    @name = _.findGood [@spec.name, "multicast-#{@id}"]


  run: ->
    throw Error("Node not ready") unless @ready()

    inputs = @inputs[0]
    outputs  = _.times @nChildren, (idx) =>
      if idx < @nChildren-1
        gg.wf.Inputs.mapLeaves(inputs, (data) -> data.clone())
      else
        inputs

    _.each outputs, (output, idx) => @output idx, output
    outputs

