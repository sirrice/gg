#<< gg/wf/node

class gg.wf.Start extends gg.wf.Node
  @ggpackage = "gg.wf.Start"

  constructor: ->
    super
    @type = "start"
    @name = "start"

  ready: -> yes

  run: ->
    data = new gg.wf.Data null
    outputs = [data]
    @output 0, outputs
    outputs


