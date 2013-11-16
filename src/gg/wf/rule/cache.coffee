#<< gg/wf/rule/rule

class gg.wf.rule.Cache extends gg.wf.rule.Rule
  @ggpackage = "gg.wf.rule.Cache"

  run: (flow) ->
    guid = @params.get 'guid'
    if @canCache()
      if @isCached guid
        @useCachers flow, guid
      else
        @addCachers flow, guid

  canCache: -> @getDB()?

  getDB: -> 
    unless window?
      return null
    unless window.localStorage?
      return null
    window.localStorage

  isCached: (guid) ->
    db = @getDB()
    ntables = db[guid]
    return no unless ntables?
    for idx in [0...ntables]
      return no unless db["#{guid}-#{idx}-table"]?
      return no unless db["#{guid}-#{idx}-md"]?
    yes

  getCacherSource: (guid) ->
    new gg.wf.CacheSource
      name: "#{guid}-cacheSource"
      params:
        guid: guid
    
  getCacher: (guid) ->
    new gg.wf.Cache
      name: "#{guid}-cacher"
      params:
        guid: guid

  addCachers: (flow, guid) ->
    @log "addCachers with guid: #{guid}"
    renderers = flow.find (n) -> n.name == 'core-render'
    return flow unless renderers.length == 1
    renderer = renderers[0]
    @log "adding cacher before #{renderer.name}"
    flow.insertBefore @getCacher(guid), renderer
    @log "insert completed"
    for p in flow.parents(renderer)
      @log "#{renderer.name} parents: #{p.name}"
    flow

  useCachers: (flow, guid) ->
    @log "useCachers with guid: #{guid}"
    source = @getCacherSource guid
    start = flow.findOne (n) -> _.isType n, gg.wf.Start
    setup = flow.findOne (n) -> n.name == 'graphic-setupenv'
    corerender = flow.findOne (n) -> n.name == 'core-render'
    facetrender = flow.findOne (n) -> n.name == 'facet-render'
    panerender = flow.findOne (n) -> n.name == 'render-panes'
    geomrenders = flow.find (n) -> 
      n.constructor.ggpackage.search("^gg.geom.svg") >= 0
    multi = new gg.wf.NoCopyMulticast {name: 'nc-multicast'}

    nodes = _.compact [
      start
      source
      setup
      multi
    ]

    layers = [
      corerender
      facetrender
      panerender
    ]

    wf = new gg.wf.Flow
    prev = null
    for n in nodes
      if prev?
        wf.connect prev, n 
        wf.connectBridge prev, n 
      prev = n

    for gr in geomrenders
      prev = multi

      for n in layers
        wf.connect prev, n
        prev = n

      wf.connect prev, gr
      wf.connectBridge multi, gr

    wf
