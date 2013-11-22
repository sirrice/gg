#<< gg/wf/node

class gg.wf.Start extends gg.wf.Node
  @ggpackage = "gg.wf.Start"
  @type = "start"

  ready: -> yes

  run: ->
    result = new data.PairTable
    @output 0, result


