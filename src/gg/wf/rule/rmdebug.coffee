#<< gg/wf/rule/node


class gg.wf.rule.RmDebug extends gg.wf.rule.Node
  compute: (node) ->
    if _.isType(node, gg.wf.Stdout) or _.isType(node, gg.wf.Scales)
      null
    else
      node
