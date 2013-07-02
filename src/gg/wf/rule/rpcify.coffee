#<< gg/wf/rule/node

#
class gg.wf.rule.RPCify extends gg.wf.rule.Node
  compute: (node) ->
    canRpcify = (node) ->
      not _.any [
        node.params.get('location') is "client"
        /layout/.test node.constructor.name.toLowerCase()
      ]

    mustRpcify = (node) ->
      node.params.get("location") is "server"

    unless /RPC/.test node.constructor.name
      if mustRpcify node
        node.location = "server"
      else if canRpcify node
        #node.location = "server"
        null
    node




