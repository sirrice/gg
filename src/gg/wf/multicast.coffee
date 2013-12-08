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
    for idx in [0...@nChildren]
      #@output idx, pairtable.clone()
      @output idx, new data.PairTable(pairtable.left(), pairtable.right())


# Creates a clone of its inputs for each child
#
# NOTE: ONLY workflow node with multiple children
#
class gg.wf.NoCopyMulticast extends gg.wf.Node
  @ggpackage = "gg.wf.NoCopyMulticast"
  @type = "nc-multicast"


  run: ->
    throw Error("Node not ready") unless @ready()

    pairtable = @inputs[0]
    #ps = pairtable.partition 'layer'

    for idx in [0...@nChildren]
      @output idx, pairtable
      #for p, idx in ps
      #@output idx, p
