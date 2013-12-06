#<< gg/wf/rule/rule

class gg.wf.rule.Server extends gg.wf.rule.Node
  @aliases = ['server']

  compute: (node) ->
    if /(render|Render)/.test node.name
      null
    else
      node


