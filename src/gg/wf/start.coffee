#<< gg/wf/node

class gg.wf.Start extends gg.wf.Node
  @ggpackage = "gg.wf.Start"
  @type = "start"

  ready: -> yes

  run: ->
    mdrow = [{}]
    md = data.Table.fromArray mdrow
    result = new data.PairTable null, md
    @output 0, result


