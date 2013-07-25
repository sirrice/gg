#<< gg/wf/rule/rule

class gg.wf.rule.EnvPut extends gg.wf.rule.Rule
  @ggpackage = "gg.wf.rule.EnvPut"

  constructor: (spec) ->
    super

  run: (flow) -> 
    # currently incorrectly implemented
    return flow




    # find all the envput nodes
    # push them to the very beginning

    pairs = {}
    puts = []
    for node in flow.nodes()
      if node.type == "envput"
        _.extend pairs, node.params.get("pairs")
        flow.rm node
        @log "removed #{node.name}"

    @log pairs

    # consolidate into single EnvPut
    envput = new gg.xform.EnvPut
      name: "envput"
      params:
        pairs: pairs

    # can't go past barriers!
    sources = flow.sources()
    for source in sources
      children = flow.children source
      if children.length > 1
        throw Error()
      if children.length == 0
        continue

      child = children[0]
      flow.insert envput, source, child
      @log "inserted new envput between #{source.name} and #{child.name}"
    
    flow



