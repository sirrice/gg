#<< gg/wf/node

class gg.wf.Start extends gg.wf.Node
  @ggpackage = "gg.wf.Start"
  @type = "start"

  ready: -> yes

  run: ->
    data = new gg.wf.Data null
    outputs = [data]
    @pstore().writeData [0], []
    @output 0, outputs
    outputs


