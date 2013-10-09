#<< gg/wf/node


# Creates a clone of its inputs for each child
#
# NOTE: ONLY workflow node with multiple children
#
class gg.wf.Multicast extends gg.wf.Node
  @ggpackage = "gg.wf.Multicast"
  @type = "multicast"


  run: ->
    throw Error("Node not ready") unless @ready()

    pairtable = @inputs[0]
    pstore = @pstore()
    for idx in [0...@nChildren]
      result = if idx is 0 then pairtable else pairtable.clone()
      @output idx, result
