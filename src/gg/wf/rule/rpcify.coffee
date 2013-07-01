#<< gg/wf/rule/node

#
class gg.wf.rule.RPCify extends gg.wf.rule.Node
  compute: (node) ->
    canRpcify = (node) ->
      not _.any [
        /RPC/.test node.constructor.name
        node.params.get('location') is "client"
      ]

    if canRpcify node
      node.location = "server"
    node




